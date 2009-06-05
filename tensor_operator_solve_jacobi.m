function X=tensor_operator_solve_jacobi( A, F, varargin )

options=varargin2options( varargin{:} );
[abstol,options]=get_option( options, 'abstol', 1e-7 );
[reltol,options]=get_option( options, 'reltol', 1e-7 );
[maxiter,options]=get_option( options, 'maxiter', 100 );
[reduce_options,options]=get_option( options, 'reduce_options', {''} );
check_unsupported_options( options, mfilename );

A0=A(1,:);
AR=A(2:end,:);

% Solve A*X=F
% "Jacobi"
% Decompose (A0+AR)*X=F
% Rewrite A0*X=F-AR*X
% Solve X(n+1)=A0\(F-AR*X(n))
% "Prec Richardson"
% Decompose M*X+(A-M)*X=F
% Rewrite M*X=
% Solve X(n+1)=M\(F-(A-M)*X(n))
% Rewrite X(n+1)=X(n)+M\(F-A*X)


function [X,flag,relres,iter]=old_tensor_operator_solve_jacobi( A, F, varargin )
% SOLVE_LINEAR_STAT_TENSOR Solves a linear system in tensor product form using stationary methods.

% init section
options=varargin2options( varargin{:} );
[M,options]=get_option( options, 'M', [] );
[abstol,options]=get_option( options, 'abstol', 1e-7 );
[reltol,options]=get_option( options, 'reltol', 1e-7 );
[maxiter,options]=get_option( options, 'maxiter', 100 );
[reduce_options,options]=get_option( options, 'reduce_options', {''} );
check_unsupported_options( options, mfilename );

%[omega,options]=get_option( options, 'overrelax', 1 ); %#ok
%[relax,options]=get_option( options, 'relax', 1.0 );
%[trunc_k,options]=get_option( options, 'trunc_k', 20 );
%[trunc_eps,options]=get_option( options, 'trunc_eps', 1e-4 );
%[algorithm,options]=get_option( options, 'algorithm', 1 ); %#ok


% solver section
A0=A(1,:);
AR=A(2:end,:);
norm_A0=tensor_operator_normest( AR ); % need to relate the truncation epsilons depending on when truncation is performed

X=tensor_null(F); 


R=compute_residual( A0, AR, X, F, reduce_options );
norm_R0=tensor_norm( R );
norm_R=norm_R0;

flag=0;
iter=0;
tol=max( norm_R0*reltol, abstol );
tol=max( tol, max( norm_R0*trunc_eps, trunc_eps ) );

% fprintf( 'Start: %g\n', norm_R0 );
while norm_R>tol

    if algorithm==1
        Y=jacobi_step_alg1( X, A0, AR, F, reduce_options );
    else
        Y=jacobi_step_alg2( X, A0, AR, F, reduce_options );
    end

    while true
        if relax<1.0
            Z=relax_update( X, Y, relax, reduce_options );
        else
            Z=Y;
        end

        R=compute_residual( A0, AR, Z, F, reduce_options );
        norm_R_new=tensor_norm( R );
        if norm_R_new>norm_R
            relax=relax/2;
            if relax<1e-2
                flag=3;
                break;
            end
        else
            break;
        end
    end
    if flag
        break;
    end
    
    X=Z;
    norm_R=norm_R_new;
    
    %fprintf( 'Iter: %d -> %g (k:%d,relax:%g)\n', iter, norm_R, size(X_r{1},2), relax );
    fprintf( 'Iter: %d -> %g (k:%d,relax:%g)\n', iter, norm_R, -1, relax );

    iter=iter+1;
    if iter>maxiter
        flag=1;
        break;
    end
end
%final_res=norm_R;
relres=norm_R/norm_R0;



function R=compute_residual( A0, AR, X, F, reduce_opts )
R=F;
R=tensor_add( R, tensor_apply( A0, X ), -1 );
R=tensor_reduce( R, reduce_opts );
for i=1:size(AR,1)
    R=tensor_add( R, tensor_apply( AR(i,:), X ), -1 );
    R=tensor_reduce( R, reduce_opts );
end


function Y=jacobi_step_alg1( X, A0, AR, F, reduce_opts )
Y=tensor_solve( A0, F );
for i=1:size(AR,1)
    S=tensor_apply( AR(i,:), X );
    S=tensor_solve( A0, S );
    Y=tensor_add( Y, S, -1 );
    Y=tensor_reduce( Y, reduce_opts );
end


function Y=jacobi_step_alg2( X, A0, AR, F, reduce_opts )
Y=F;
for i=1:size(AR,1)
    S=tensor_apply( AR(i,:), X );
    Y=tensor_add( Y, S, -1 );
    Y=tensor_reduce( Y, reduce_opts );
end
Y=tensor_solve( A0, Y );


function Z=relax_update( X, Y, relax, reduce_opts )
Z=tensor_add( Y, Y, relax-1 );
Z=tensor_add( Z, X, 1-relax );
Z=tensor_reduce( Z, reduce_opts  );

function bool=check_tensors_compatible( T1, T2 )
% CHECK_TENSORS_COMPATIBLE Checks that tensors have same format and order.
%   CHECK_TENSORS_COMPATIBLE( T1, T2 ) checks that the tensors T1 and T2
%   have the same format and otherwise issues an error.
%
% Example (<a href="matlab:run_example check_tensors_compatible">run</a>)
%
% See also

%   Elmar Zander
%   Copyright 2010, Inst. of Scientific Comuting
%   $Id$ 
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version. 
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.

[bool1,format1]=istensor(T1);
[bool2,format2]=istensor(T2);

if ~bool1 || ~bool2
    error( 'tensor:no_tensor', ...
        'No recognized tensor format' );
end
if ~strcmp(format1,format2)
    error( 'tensor:different_formats', ...
        'Tensors have different tensor formats' );
end

if iscell(T1)
    if length(T1)~=length(T2)
        error( 'tensor:different_order', 'Tensors have different order' );
    end
    
    sz1=cellfun( 'size', T1, 1 );
    sz2=cellfun( 'size', T2, 1 );
    
    if any(sz1~=sz2)
        error( 'tensor:dimension_mismatch', 'Tensors have different dimensions' );
    end
end
    
bool=true;

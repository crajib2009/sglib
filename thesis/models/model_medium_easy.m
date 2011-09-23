% identification
model=mfilename;

% load continuous model
model_continuous_easy

% geometry discretisation
num_refine=1;
num_refine_after=0;

% right hand side
m_f=6;
p_f=3;
l_f=6;

% coefficient field
m_k=5;
p_k=3;
l_k=5;

% dirirchlet boundary conditions
m_g=0;
p_g=1;
l_g=0;

% neumann boundary conditions
m_h=0;
p_h=1;
l_h=0;

% solution
p_u=3;

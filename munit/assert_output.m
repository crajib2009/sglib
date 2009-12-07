function assert_output( command, expected_output, assert_id )
% ASSERT_OUTPUT Short description of assert_output.
%   ASSERT_OUTPUT Long description of assert_output.
%
% Example (<a href="matlab:run_example assert_output">run</a>)
%
% See also

%   Elmar Zander
%   Copyright 2009, Inst. of Scientific Computing, TU Braunschweig
%   $Id$ 
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version. 
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.

if exist('evalc') %#ok
    if ~isempty(expected_output)
        expected_output=sprintf(expected_output);
    end
    assert_equals( evalc(command), expected_output, assert_id );
end

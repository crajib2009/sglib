function [bool,format]=istensor(T)
% ISTENSOR Checks whether object is in a recognized tensor format.
%   BOOL=ISTENSOR(T) returns true if T is in a recognized tensor format.
%   Currently that means that T may be a full tensor or in canonical
%   format. (Tucker format will follow).
%
% Example (<a href="matlab:run_example istensor">run</a>)
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

bool=false;
format='';

if isnumeric(T)
    bool=true;
    format='full';
    return;
elseif iscell(T)
    if ~isvector(T)
        return;
    end
    isnum=cellfun(@isnumeric, T );
    if ~all(isnum)
        return
    end

    ndims=cellfun( 'ndims', T );
    dim2=cellfun( 'size', T, 2 );
    
    % first check for canonical format
    if all(ndims==2) && all(dim2(:)==dim2(1))
        bool=true;
        format='canonical';
        return;
    end
    
    % not canonical, try tucker (i.e. first ones is core tensor);
    if ndims(1)==length(T)-1 && all(ndims(2:end)==2)
        dim1=cellfun( 'size', T, 1 );
        if all(dim2(2:end)==dim2(2)) && all(dim1(2:end)==ndims(1))
            bool=true;
            format='tucker';
            return;
        end
    end
elseif isobject(T)
    bool=true;
    format=['class:' class(T)];
end

    
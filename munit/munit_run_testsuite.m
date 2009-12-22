function munit_run_testsuite( varargin )
% MUNIT_RUN_TESTSUITE Runs all tests in one directory.
%   MUNIT_RUN_TESTSUITE( MODULE_NAME, CURR_DIR ) runs all tests (contained
%   in M-files matching "unittest_*.m") in the directory specified by CURR_DIR
%   under the module name MODULE_NAME.
%
% Options:
%   dir: <current working directory (pwd)>
%     The directory in which the testsuite is run.
%   subdirs: {auto}
%     Runs MUNIT_RUN_TESTSUITE recursively in all subdirectories. Passing
%     a cell array of relative pathnames runs MUNIT_RUN_TESTSUITE only in
%     the given subdirs. Default is empty cell array ({}).
%   prefix: 'unittest_'
%     The file prefix used for locating unit tests. All files beginning
%     with that prefix are considered unit tests automatically. Note: It
%     was deliberate by the author to choose the longer name 'unittest' as
%     default, since it happend to often, that one writes some file
%     'test_xyz' to try out something, which is no true unit test.
%   coverage: false
%     Create and show a coverage report for this run. This indicates to
%     you, whether all functions in the current dir have been thoroughly
%     tested. Since this functions relies on the profiler and the coverage
%     report feature this option is only available in matlab version from
%     probably 7 onward.
%
% Example
%   munit_reset_options();
%   munit_set_debug( true );
%   munit_run_testsuite( 'mymod', pwd, 'subdirs', {'submod1', 'submod2'} );
%
% See also 

%   Elmar Zander
%   Copyright 2006, Institute of Scientific Computing, TU Braunschweig.
%   $Id$
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
%   See the GNU General Public License for more details. You should have
%   received a copy of the GNU General Public License along with this
%   program.  If not, see <http://www.gnu.org/licenses/>.

options=varargin2options( varargin );
[subdirs,options]=get_option( options, 'subdirs', 'auto' );
[prefix,options]=get_option( options, 'prefix', munit_options('get','prefix') );
[curr_dir,options]=get_option( options, 'dir', pwd );
[module_name,options]=get_option( options, 'module_name', '' );
[coverage,options]=get_option( options, 'coverage', false );
[level,options]=get_option( options, 'level', 1 );
check_unsupported_options( options, mfilename );

if isempty(module_name)
    [dummy,module_name]=fileparts(curr_dir);
    dummy; %#ok
end

% get subdirs
if ischar( subdirs ) && strcmp( subdirs, 'auto' )
    subdirs={};
    files=dir(curr_dir);
    for i=1:length(files)
        file=files(i);
        if file.isdir && file.name(1)~='.';
            subdirs{end+1}=file.name; %#ok<AGROW>
        end
    end
end

% 
if level==1
    munit_stats('reset');
end
munit_stats('push', module_name );
munit_printf('debug', 'Entered module (%d): %s', {level, module_name});

% for coverage report we need to start profiling
if coverage
    profile('on');
end

% first go through subdirs
for subdir=subdirs
    munit_run_testsuite( 'subdirs','auto', 'prefix', prefix, ...
        'dir', fullfile(curr_dir, subdir{1}), ...
        'module_name', subdir{1}, ...
        'level', level+1);
end

% go through unittests in this dir
pattern=sprintf( '%s/%s*.m', curr_dir, prefix );
files=dir( pattern );

if ~isempty(files) || level==1
    munit_printf('module', 'Testing module (%d): %s', {level, module_name});
end

for i=1:length(files)
    test_cmd=files(i).name(1:end-2);
    munit_printf( 'file', 'Running: %s', {fullfile(module_name, test_cmd)} );

    slash_pos=find(test_cmd=='/');
    if ~isempty(slash_pos)
        test_cmd=test_cmd( slash_pos(end)+1:end );
    end

    safe_eval( test_cmd );
end

if ~isempty(files) || level==1
    munit_print_stats();
end
munit_stats('pop' );

% need to end profiling if we have started
if coverage
    profile('off');
    if curr_dir(1)=='/'
        full_dir=curr_dir;
    else
        full_dir=fullfile(pwd,curr_dir);
    end
    coveragerpt(full_dir);
end


function safe_eval( unittest_cmd )
% MUNIT_SAFE_FEVAL Evaluate command safely.
%
% If we call eval(test_cmd) directly from MUNIT_RUN_TESTSUITE and the
% command is a script and clears the workspace (yes, this happens) we have
% a problem. Putting this into a separate functions separates the
% workspaces and so the user can do whatever he likes in 'test_cmd'.
eval( unittest_cmd );
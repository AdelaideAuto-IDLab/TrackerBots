%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -DESCRIPTION
%   Running complicated tasks sometimes take huge amount of execution time in matlab. Supose you want to stop running a command, 
%   if it takes too much execution time, then this is the code for you. Using function 'evalWithTimer', you can spcify the command to execute (1st input),
%   and maximum time-limit in seconds (2nd input). If the command execution takes more time than the specified time-limit, then this program 
%   automatically kills the process and returns a non-zero status value. See Examples below for more info. 
%
% -INPUTS
%  'cmdStr'   : Command to execute in string format
%  'waitTime' : Maximum execution time permitted in seconds
%
% -OUTPUTS
%  'status' => '0' When command got succesfully executed within the time.
%              '1' Otherwise  
%
% -EXAMPLES
%   1. Compute the square root of 123 within 100 seconds, and store it in variable 'a' in the workspace 
%       status = evalWithTimer('a=sqrt(123)',100)
%   2. Solve a linear program with 'n' variables in 1 hour
%       n=10^5; A=rand(n)-0.5; b = rand(n,1)-0.5; f = rand(n,1)-0.5;
%       status = evalWithTimer('x = linprog(f,A,b)',3600)
%
% -NOTES:
%   1. Make sure that, 'matlab' command is runnable in Terminal, by adding symbolic links to any of the PATH 
%       eg:  ln -s /Applications/MATLAB_R2015b.app/bin/matlab /usr/local/bin/
%       eg: ln -s /usr/local/MATLAB/R2016b/bin/matlab /usr/local/bin/
%   2. This program runs only in UNIX based OS, which includes LINUX & OSX. This program won't run in WINDOWS!! 
%
% -TROUBLESHOOTS
%   1. Inputs can't be a structure: For example, "s.a=12; evalWithTimer('b=sqrt(s.a)',100)" is invalid, whereas "evalWithTimer('s.b=sqrt(a)',100)" is valid   
%   2. Make sure that all required files are present in matlab PATH. This function invoke a new instance of matlab, hence the PATH set locally won't be counted! 
%
% -VERSIONS
%   Version 1 release: 13 September 2016 
%
% -AUTHOR
%   Anver Hisham <anverhisham@gmail.com>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function status = evalWithTimer(cmdStr,waitTime)

%% -Check if matlab is present in the PATH
% [~,isMATLABnotPresent] = system('source ~/.bash_profile; which matlab > /dev/null 2>&1; echo $?');
% isMATLABnotPresent = str2double(isMATLABnotPresent);
% assert(~isMATLABnotPresent,'Error: MATLAB is not present in system PATH. Consider creating a symbolic link to matlab in any of the system path');

[~,currentFolder] = system('pwd');
currentFolder = currentFolder(1:end-1);
%% -Split the 'cmdStr' into outArg{:}, function-handle (fh), and inArgs{:} ([outArgs{:}] = fh(inArgs{:}))  
word = '[a-zA-Z](\w|\.)*';
ind1 = regexp(cmdStr,'[^=]=[^=]');
% -Get all input argument names from RHS
cmdRHS = cmdStr(ind1+2:end);
ind2 = regexp(cmdRHS,'(');
inArgsExpr = cmdRHS(ind2+1:end-1);
inArgs = regexp(inArgsExpr,word,'match');   %% Array of cells of strings, with each string containing inputted variable-name
for iinArgs = 1:numel(inArgs)
    if(~isempty(which(inArgs{iinArgs})))    %% If inArgs{iinArgs} is a function name
        inArgs(iinArgs) = [];
    end
end

%% -Save the variables to files
fileName = [datestr(now,'yyyymmddHHMMSSFFF'),'_timerCommand'];
fileName_mat = [fileName,'.mat'];
fileName_sh = [fileName,'.sh'];
if(~isempty(inArgs))
    evalin('caller',['save(''',fileName_mat,''',',cell2string(inArgs),');']);
end

%% -Construct MATLAB expression
cmdFinal = '';
if(~isempty(inArgs))
    cmdFinal = [cmdFinal,'load(''',fileName_mat,''');'];    %% load all input variables
end
cmdFinal = [cmdFinal,cmdStr,';'];                           %% Execute the command
cmdFinal = [cmdFinal,'save(''',fileName_mat,''');'];        %% Save all the output variables to a file
cmdFinal = ['source ~/.bash_profile; p=`pwd`; matlab -nodisplay -nosplash -r "cd $p; ',cmdFinal,' exit" </dev/null '];
fid=fopen(fileName_sh,'w'); fprintf(fid,cmdFinal); fclose(fid);

%% -Execute Command
t = clock;
% p=`pwd`; nohup matlab -nodisplay -nosplash -r "cd $p; matlabFunction1; exit" </dev/null  >simulationOutput.out 2>&1 &
% [~,PID] = system('sh -c ''ls >temp.log; sleep 60;''  2>&1 & echo $!');
[~,PID] = system(['chmod a+x ',fileName_sh,'; sh -c "./',fileName_sh,';"  >evalWithTimer.log 2>&1 & echo $!']);     %% PID is a string with eding newline
PID = PID(1:end-1);                                                             %% Removing trailing newline

while(etime(clock,t)<waitTime)
    %% -If process not running, then return
    [~,isProcessNotRunning] = system(['ps -p ',PID,' > /dev/null 2>&1; echo $?']);
    if(str2double(isProcessNotRunning))
        evalin('caller',['load(''',currentFolder,'/',fileName_mat,''');']);     %% -Loading all outputs to caller's worspace 
        status = 0;
        break;
    end
    pause(1);
end

%% -If simulation takes long time, then Kill the process and all its child processes
if(~exist('status','var') || status~=0)
    system(['kill -9 -$(ps -o pgid= ',num2str(PID),' | grep -o ''[0-9]*'')']);
    status = 1;
end

%% -Delete all the temporary files
system(['rm ',fileName_mat,'  ',fileName_sh,';']);

end



%% {'a','bc','def'}  ->  '''a'',''bc'',''def'''
function outString = cell2string(inCell)
    outString = '';
    for iinCell = 1:numel(inCell)
        outString = [outString,'''',inCell{iinCell},'''',','];
    end
    if(~isempty(outString))     %% -Removing trailing comma
        outString(end) = [];
    end
end

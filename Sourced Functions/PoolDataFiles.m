function [CellProps,poolProps,poolIms,poolFiles] = PoolDataFiles()
%POOLDATAFILES Pool ImDat and CellProps files (output of vestibular
%analysis.
%   Detailed explanation goes here

state = true;
path = pwd;
poolIms = {};
poolProps = {};

n=0;
while state
    %% Read files that have the same pool. 
    [file,path] = uigetfile('*.mat','Select Files to Pool. Cancel to finish.',path,'MultiSelect','on');
    if ischar(file)
        file = {file};
    end
    
    if iscell(file)&&ischar(file{1})
    %% name the group
    prompt = {'Enter Group Name'};
    dlgtitle = 'Input';
    dims = [5];
    definput = {'group'};
    type = string(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));
    pathdef = path;
    %% Read in Files
        for k = 1:length(file)
            n=n+1;
            load([path file{k}],'ImDat','CellProps')
            CellProps.Type = repmat(type,[height(CellProps) 1]); % add type column.
            CellProps.Replicate = repmat(k,[height(CellProps) 1]); % add replicate column. 
            poolProps{n} = CellProps;
            poolTypes{n} = type;
            poolReplicate{n} = k;
            poolIms{n} = ImDat;
            poolFiles{n} = file{k};
            
        end
    else
        state = false;
    end
end

% concatenate all pooled property data
CellProps = poolProps{1};
for m = 2:n
    CellProps = [CellProps; poolProps{m}];
end

if nargout==0
    [outfile,outpath] = uiputfile('*.mat','Save pooled data file',pathdef);
    
    if ischar(outfile)
        save([outpath outfile],'CellProps','poolProps','poolIms','poolFiles','poolReplicate','poolTypes');
    end
end

end


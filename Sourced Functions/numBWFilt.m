function [bwOut] = numBWFilt(bwIn,nComps,varargin)
%NUMBWFILT Filter image based upon number of binary components
%
%   [bwOut] = numBWFilt(BW,1) keep images with only 1 binary component
%
%   [bwOut] = numBWFilt(BW,2,'geq') keep images with two or more binary
%   components
%% parse inputs
p = inputParser;

% add inputs
addRequired(p,'BW');
addRequired(p,'nComps',@isnumeric);

validFilts = {'range','gt','lt'};
checkFilts = @(x) any(validatestring(x,validColors));

addOptional(p,'filtspec','range',checkFilts);

parse(p,bwIn,nComps,varargin{:});

% extract parameters
filtspec = p.Results.filtspec;

%% Count binary components
nBW = numBWComps(bwIn);

%% Filter
state=0;
switch filtspec
%     case "eq"
%         if nBW==nComps
%             state=1;
%         end
%     case "geq"
%         if nBW>=nComps
%             state=1;
%         end
%     case "leq"
%         if nBW<=nComps
%             state=1;
%         end
    case {"gt","topn"}
        if nBW>nComps
            state=1;
        end
    case {"lt","botn"}
        if nBW<nComps
            state=1;
        end
    case "range"
        if length(nComps)==2
            nComps=sort(nComps);
            if nBW>=nComps(1)&&nBW<=nComps(2)
                state=1;
            end
        elseif length(nComps)==1
            if nBW==nComps
                state=1;
            end
        else
            error('Invalid range');
        end
end

%% output
if state==1
    bwOut = bwIn;
else
    bwOut = false(size(bwIn));
end

end


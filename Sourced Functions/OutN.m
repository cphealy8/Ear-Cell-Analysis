function Z = OutN(N,FUN,varargin)
% Z = Out2(FUN,VARARGIN);
%
%	Provides the Nth output from the function
switch N
    case 2
        [~,Z] = FUN(varargin{:});
    case 3
        [~,~,Z] = FUN(varargin{:});
    case 4
        [~,~,~,Z] = FUN(varargin{:});
    case 5
        [~,~,~,~,~,Z] = FUN(varargin{:});
end
end
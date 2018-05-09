clear
close all
clc

filename = './build/test.fifo';
fid = fopen(filename,'r');
k = [];

fgets(fid);
tline = fgets(fid);
np = 0;
Y = [];
while tline ~= -1
    
    if tline(1) ~= '#'
        try
            eval(tline);
            Y = [Y;X];
            np = np+1;
        catch e
        end
    end
    
    try
        plot(abs(X))
        title(num2str(np))
        % xlim([-2 2])
        % ylim([-2 2])
        drawnow limitrate
    catch e
    end
    tline = fgets(fid);
end
fclose(fid);
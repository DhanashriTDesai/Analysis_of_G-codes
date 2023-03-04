clear; clc; close all; % Housekeeping commands

fileName = 'Customized_Cube104mm';
OriginalGcode = readlines(strcat('SingleLayerOriginalGcode_',fileName,'.dat'));
nNonExtr=0; nExtr=0; tNonExtr=[]; tExtr=[];
vPrint=7; vTravel=60;
fileID = fopen(strcat('SingleLayerProcessedGcode_',fileName,'.dat'),'w'); 
for i=1:length(OriginalGcode)
    c=convertStringsToChars(OriginalGcode(i));
    if c(4:8)=='F3600'
        c(4:9)=[];
    elseif c(4:7)=='F420'
        c(4:8)=[];
    end
    if i~=length(OriginalGcode)
        fprintf(fileID,strcat(c,'\n'));
    else
        fprintf(fileID,c);
    end
end
clear c; fclose(fileID); 

ProcessedGcode = readlines(strcat('SingleLayerProcessedGcode_',fileName,'.dat'));
for i=1:length(ProcessedGcode)
    L1=convertStringsToChars(ProcessedGcode(i));
    spacesC1 = find(L1==' ');
    x1Start=5; x1End=spacesC1(2)-1; y1Start=x1End+3;
    x2Start=5;
    x1=str2double(L1(x1Start:x1End));
    if i~=1
        L2=convertStringsToChars(ProcessedGcode(i-1));
        spacesC2 = find(L2==' ');
        x2End=spacesC2(2)-1; y2Start=x2End+3;
        x2=str2double(L2(x2Start:x2End));
        if size(spacesC2,2)==2
            y2End=length(L2);
        else
            y2End=spacesC2(3)-1;
        end
        y2=str2double(L2(y2Start:y2End));
    else
        x2=0; y2=0;
    end
    dx=abs(x1-x2);
    if L1(1:2)=='G0' % Non-extrusion moves
        nNonExtr=nNonExtr+1;
        y1End=length(L1); y1=str2double(L1(y1Start:y1End));
        dy=abs(y1-y2);
        tNonExtr(nNonExtr)=sqrt(dx^2 + dy^2)/vTravel; 
    else % Extrusion moves
        nExtr=nExtr+1;
        if size(spacesC1,2)==2
            y1End=length(L1); 
        else
            y1End=spacesC1(3)-1; 
        end        
        y1=str2double(L1(y1Start:y1End)); dy=abs(y1-y2);
        tExtr(nExtr)=sqrt(dx^2 + dy^2)/vPrint; 
    end
end
tExtr=tExtr'; ExtrusionTimeSec=sum(tExtr);
tNonExtr=tNonExtr'; NonExtrusionTimeSec=sum(tNonExtr);
[q,r]=quorem(sym(round(ExtrusionTimeSec)),sym(60));
disp(['Extrusion time: ' num2str(str2num(string(q))) 'min  ' num2str(str2num(string(r))) 'sec'])
% [q,r]=quorem(sym(round(NonExtrusionTimeSec)),sym(60));
% disp(['Non-Extrusion time: ' num2str(str2num(string(q))) 'min  ' num2str(str2num(string(r))) 'sec'])

%% Plotting
GridSize = [2 3 4 5 6];
tExtrCE = [171 337 557 839 1168];
tExtrCustom = [68 140 238 361 510];
tNonExtrCE = [3 5 10 16 20];
tNonExtrCustom = [2 4 7 9 13];
figure(1);
plot(GridSize,tExtrCE,'-ko',GridSize,tExtrCustom,'-ks',LineWidth=4,MarkerSize=18);
NameTheGraphModified('$$\mathrm{\mathbf{Grid\;size\;of\;Diamond\;celled\;frame}}$$','$$\mathrm{\mathbf{t}}_\mathrm{\mathbf{Extrusion}}$$ \textbf{[sec]}',[],2,'$$\;\mathrm{\mathbf{CURA\;toolpath}}$$','$$\;\mathrm{\mathbf{Customized\;toolpath}}$$',[],[],[],[],[],[],'NorthEast');
xlim([1.5 7]); ylim([0 1500]);
figure(2);
plot(GridSize,tNonExtrCE,'-ko',GridSize,tNonExtrCustom,'-ks',LineWidth=4,MarkerSize=18);
NameTheGraphModified('$$\mathrm{\mathbf{Grid\;size\;of\;Diamond\;celled\;frame}}$$','$$\mathrm{\mathbf{t}}_\mathrm{\mathbf{Non-extrusion}}$$ \textbf{[sec]}',[],2,'$$\;\mathrm{\mathbf{CURA\;toolpath}}$$','$$\;\mathrm{\mathbf{Customized\;toolpath}}$$',[],[],[],[],[],[],'NorthEast');
xlim([1.5 7]); ylim([0 25]);

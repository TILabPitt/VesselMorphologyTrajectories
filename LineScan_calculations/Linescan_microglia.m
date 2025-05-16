T = 0.5; % block size in s
write_filename = 'Z:\Students\Yucheng\Linescan20250509.xlsx'; %excel filename for output 
sourcedir = ''; % enter dir of source files


% it does not matter how long do we average the rbcv - can average it after
% computing the rbcv time series
count = 1;
cd(sourcedir)
listing = dir;

for i = 1:length(listing)
      if ~(strcmp(listing(i).name,'.DS_Store')) & ~(strcmp(listing(i).name,'..')) & ~(strcmp(listing(i).name,'.'))
            subdir = fullfile(sourcedir,listing(i).name);
            cd(subdir);
            listing2 = dir;
            for j = 1:length(listing2)
                  if ~(strcmp(listing2(j).name,'.') & ~(strcmp(listing2(j).name,'..'))) & ~(strcmp(listing2(j).name,'.DS_Store'))
                        subsubdir = fullfile(subdir,listing2(j).name);
                        cd(subsubdir);
                        imlist = dir('*.tif');
                        xmllist = dir('*.xml');
                        for k    = 1:length(imlist)
                              imname = imlist(k).name;
                              if contains(imname,'Ch2') & ~contains(imname,'Source')
                                    tmpstk=tiffread2(imname);
                                    lineim = double(tmpstk.data);
                                    parsed = parsePrairieXML2(xmllist.name);
                                    dx_dt = [parsed.PV_shared.micronsPerPixel{1}, parsed.PV_shared.scanLinePeriod];
                                    dtcheck(count) = dx_dt(2);
                                    clear vel,clear vel0, clear rnln, clear rsnr, clear sscore, clear ssm
                                    blocklim = min(round(T/dx_dt(2)),size(lineim,1)); %defines how many lines included in T
                                    norm = min(20*blocklim,size(lineim,1)); % define lines used for normalization
                                    % pick all cols
                                    colpick = size(lineim,2);
                                    lparms=[blocklim blocklim norm 1 round(colpick) 2];
                                    sparms = 12; % compared with angles 180/sparms*[1:sparms]
                                    % rtype = 4 for radon
                                    figure(1)
                                    [vel,vel0,ang,rsnr] =lineScan_velEstRot4(lineim,lparms,sparms,dx_dt,4);
                                    try
                                          writematrix(listing(i).name,write_filename,'Sheet','vel','Range',strcat('A',num2str(count)));% write file name
                                          writematrix(listing(i).name(1:8),write_filename,'Sheet','vel','Range',strcat('B',num2str(count)));% write file name
                                          writematrix(listing2(j).name(end-7:end),write_filename,'Sheet','vel','Range',strcat('C',num2str(count)));% write file name
                                          tmpidx = find(imname == '-');
                                          writematrix(imname((tmpidx(2)+1):end),write_filename,'Sheet','vel','Range',strcat('D',num2str(count)));
                                          newvel = abs(vel/1000);
                                          newvel(rsnr<3) = nan;
                                          writematrix(newvel,write_filename, 'Sheet','vel','Range',strcat('G',num2str(count))); % write in vel
                                    catch ME
                                
                                          logFile = fullfile('Y:\Students\Yucheng\write_error_log.txt');  

                                          fid = fopen(logFile, 'a');  
                                          if fid ~= -1
                                                fprintf(fid, '==== %s ====\n', datestr(now));
                                                fprintf(fid, 'Error during writing Excel file\n');
                                                fprintf(fid, 'listing(i).name: %s\n', listing(i).name);
                                                fprintf(fid, 'listing2(j).name: %s\n', listing2(j).name);
                                                fprintf(fid, 'imname:%s\n',imname((tmpidx(2)+1):end))
                                                fprintf(fid, 'vel: %s\n', newvel);
                                                fprintf(fid, 'Error message: %s\n', ME.message);

                                                if ~isempty(ME.stack)
                                                      fprintf(fid, 'In file: %s\n', ME.stack(1).file);
                                                      fprintf(fid, 'At line: %d\n', ME.stack(1).line);
                                                end
                                                fprintf(fid, '\n');
                                                fclose(fid);
                                          else
                                                warning('Cannot open error log');
                                          end

                                    end
                                    count = count +1;
                              end
                        end
                        cd ..
                  end

            end
            cd ..
      end
end
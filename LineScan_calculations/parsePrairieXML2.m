function [h,c]=parsePrairieXML(dname,config_flag)
% Usage ... header=parsePrairieXLM(fname)
% Requires xml_io library
% Returns a simplified structure that serves as a header

do_ver=5;

if nargin<2, config_flag=0; end;
%disp(sprintf('  config_flag= %d',config_flag));

if ~(strcmp(dname(end-3:end),'.xml')|strcmp(dname(end-3:end),'.XML')),
  if strcmp(dname(end),filesep),
    tmpxdir=dir([dname,'*.xml']);
    tmpcdir=dir([dname,'*.cfg']);
    fname=[tmpxdir(1).folder,filesep,tmpxdir(1).name];
    cname=[tmpxdir(1).folder,filesep,tmpxdir(1).name(1:end-4),'Config.cfg'];
    %fname=sprintf('%s/%s.xml',dname,dname(1:end-1));
    %cname=sprintf('%s/%sConfig.cfg',dname,dname(1:end-1));
  else,
    tmpxdir=dir([dname,'*.xml']);
    tmpcdir=dir([dname,'*.cfg']);
    fname=[tmpxdir(1).folder,filesep,tmpxdir(1).name];
    cname=[tmpxdir(1).folder,filesep,tmpxdir(1).name(1:end-4),'Config.cfg'];
    %fname=sprintf('%s/%s.xml',dname,dname);
    %cname=sprintf('%s/%sConfig.cfg',dname,dname);
  end;
else,
  fname=dname;
  cname=sprintf('%sConfig.cfg',dname(1:end-3));
  %disp(sprintf(' config file= %s\n',cname));
end;

%disp(sprintf(' xml file= %s\n',fname));

a=xml_read(fname);

if isfield(a,'SystemConfiguration'),
    disp('  PV ver3 detected...');
    do_ver=3; 
end;

 if do_ver==5,
  if isfield(a,'SystemIDs'),
      h.SystemID.Name=a.SystemIDs.SystemID.ATTRIBUTE.Description;
      h.SystemID.SystemID=a.SystemIDs.SystemID.ATTRIBUTE.SystemID;
  end
  %if isfield(a,'Sequence'),
  %  if length(a.Sequence)>1, h=a; return; end;
  %end;
  h.date=a.ATTRIBUTE.date;
  % parse PVShard
  for mm=1:length(a.PVStateShard.PVStateValue),
    tmp=a.PVStateShard.PVStateValue(mm);
    if length(tmp.IndexedValue)==1,
      for nn=1:length(tmp.IndexedValue),
        eval(sprintf('h.PV_shared.%s=tmp.IndexedValue(nn).ATTRIBUTE.value;',tmp.ATTRIBUTE.key));
      end;
    elseif length(tmp.IndexedValue)>1,
      for nn=1:length(tmp.IndexedValue),
        eval(sprintf('h.PV_shared.%s{nn}=tmp.IndexedValue(nn).ATTRIBUTE.value;',tmp.ATTRIBUTE.key));
      end;
    else,
      if isfield(tmp.ATTRIBUTE,'value'),
        tmpval=tmp.ATTRIBUTE.value;
      elseif isfield(tmp,'SubindexedValues'),
        clear tmpval
        if length(tmp.SubindexedValues(1).SubindexedValue)==1,
          for oo=1:length(tmp.SubindexedValues),
            %tmp.SubindexedValues(oo).SubindexedValue.ATTRIBUTE.value,
            for qq=1:length(tmp.SubindexedValues(oo).SubindexedValue),
              tmpval{oo}{1}(qq)=tmp.SubindexedValues(oo).SubindexedValue(qq).ATTRIBUTE.value;
            end
            tmpval{oo}{2}=tmp.SubindexedValues(oo).ATTRIBUTE.index;
          end;
        else,
          for oo=1:length(tmp.SubindexedValues.SubindexedValue),
            tmpval{oo}{1}=tmp.SubindexedValues.SubindexedValue(oo).ATTRIBUTE.value;
            tmpval{oo}{2}=tmp.SubindexedValues.SubindexedValue(oo).ATTRIBUTE.description;
          end;
        end;
      else,
        tmpval=[];
      end;
      eval(sprintf('h.PV_shared.%s=tmpval;',tmp.ATTRIBUTE.key));
    end;
  end;
  
  % parse Line Sequence if present
  %if isfield(a.Sequence,'PVLinescanDefinition') && length(a.Sequence) <= 1,
  if isfield(a.Sequence,'PVLinescanDefinition'),
    for ii = 1:length(a.Sequence)

        % If frame field not present, return without parsing
        if ~isfield(a.Sequence, 'Frame')
            warning('Frame feild not found in XML file. Continuing without parsing XML ...')
            return;
        end

        if length(a.Sequence(ii).Frame) == 1
          tmpfld=fieldnames(a.Sequence(ii).PVLinescanDefinition.ATTRIBUTE);
          for oo=1:length(tmpfld), 
              eval(sprintf('tmpval=a.Sequence(ii).PVLinescanDefinition.ATTRIBUTE.%s;',tmpfld{oo}));
              eval(sprintf('h.LineInfo(ii).%s=tmpval;',tmpfld{oo}));
          end
          if isfield(a.Sequence(ii).PVLinescanDefinition,'Freehand'),
              for oo=1:length(a.Sequence(ii).PVLinescanDefinition.Freehand),
                  h.LineInfo(ii).Freehand(oo,1)=a.Sequence(ii).PVLinescanDefinition.Freehand(oo).ATTRIBUTE.x;
                  h.LineInfo(ii).Freehand(oo,2)=a.Sequence(ii).PVLinescanDefinition.Freehand(oo).ATTRIBUTE.y;
              end
              if isfield(a.Sequence(ii).PVLinescanDefinition,'PVFreehand'),
              for oo=1:length(a.Sequence(ii).PVLinescanDefinition.PVFreehand),          
                  h.LineInfo(ii).PVFreehand(oo,1)=a.Sequence(ii).PVLinescanDefinition.PVFreehand(oo).ATTRIBUTE.x;
                  h.LineInfo(ii).PVFreehand(oo,2)=a.Sequence(ii).PVLinescanDefinition.PVFreehand(oo).ATTRIBUTE.y;
              end
              end
              if isfield(a.Sequence(ii).PVLinescanDefinition,'PVSpiral'),
                  h.LineInfo(ii).PVSpiral=a.Sequence(ii).PVLinescanDefinition.PVSpiral.ATTRIBUTE;
              end
          end
        else
            h.LineInfo(ii).SourceLinesPerFrame = [];
            h.LineInfo(ii).SourcePixelsPerLine = [];
            h.LineInfo(ii).mode = [];
            h.LineInfo(ii).scanContinuous = [];
            h.LineInfo(ii).Freehand = [];
            h.LineInfo(ii).PVFreehand = [];
        end
    end
  end
  
  % parse Frames Sequence
  %frameItems={'laserPower','twophotonLaserPower'};
  frameItems={'laserPower','twophotonLaserPower','FramePeriod','linesPerFrame','pixelsPerFrame','scanLinePeriod'};
  frameSubItems={'positionCurrent','pmtGain'};

  % Get number of cycles
  h.nCycles=length(a.Sequence);

  % Initialize frames to loop (eliminate line scan/image mix)
  h.Frames = [];

  % Check if line scan and image mix
  containsLine = [];
  if isfield(h, 'LineInfo')
      for ii = 1:length(h.LineInfo)
          if isempty(h.LineInfo(ii).mode)
            containsLine(ii) = false;
          else
              containsLine(ii) = true;
          end
      end
  end

  for ss=1:length(a.Sequence)

    if length(a.Sequence(ss).Frame) == 0
        h.FramesAll{1, ss} = 'No Frames in this cycle';
        h.ValidFramesAll(ss) = 0;
    end

    for mm=1:length(a.Sequence(ss).Frame), 
        h.ValidFramesAll(ss) = length(a.Sequence(ss).Frame);
        for nn=1:length(a.Sequence(ss).Frame(mm).File),
          h.FramesAll{mm,ss}.fname{nn}=a.Sequence(ss).Frame(mm).File(nn).ATTRIBUTE;
        end;
        h.FramesAll{mm,ss}.absTime=a.Sequence(ss).Frame(mm).ATTRIBUTE.absoluteTime;
        h.FramesAll{mm,ss}.relTime=a.Sequence(ss).Frame(mm).ATTRIBUTE.relativeTime;
        
        % Make frames into Array using valid frames (take images only if linescan
        % is included. Else, Add whatever is in frames to array
        if ~isfield(h, 'LineInfo')
            h.Frames = [h.Frames h.FramesAll{mm, ss}];
        else
            if isempty(h.LineInfo(ss).mode) % Case current frame is not a line scan
                h.Frames = [h.Frames h.FramesAll{mm, ss}];
            elseif all(containsLine)    % Case only line scan
                h.Frames = [h.Frames h.FramesAll{mm, ss}];
            end
        end
    
        if ~isempty(a.Sequence(ss).Frame(mm).PVStateShard),
        for nn=1:length(a.Sequence(ss).Frame(mm).PVStateShard.PVStateValue),
          tmp=a.Sequence(ss).Frame(mm).PVStateShard.PVStateValue(nn);
          for oo=1:length(frameItems),
            if strcmp(frameItems{oo},tmp.ATTRIBUTE.key),
              if isfield(tmp.ATTRIBUTE,'value'),
                tmpval=tmp.ATTRIBUTE.value;
                eval(sprintf('h.FramesAll{mm,ss}.%s=tmpval;',frameItems{oo}));
              else,
                for ooo=1:length(tmp.IndexedValue), tmpval(ooo)=tmp.IndexedValue(ooo).ATTRIBUTE.value; end;
                eval(sprintf('h.FramesAll{mm,ss}.%s=tmpval;',frameItems{oo}));
              end
            end;
          end;
          for oo=1:length(frameSubItems),
            if strcmp(frameSubItems{oo},tmp.ATTRIBUTE.key),
              if isfield(tmp,'SubindexedValues'), for qq=1:length(tmp.SubindexedValues),
                for rr=1:length(tmp.SubindexedValues(qq).SubindexedValue), tmpval(rr)=tmp.SubindexedValues(qq).SubindexedValue(rr).ATTRIBUTE.value; end;
                eval(sprintf('h.FramesAll{mm,ss}.%s=tmpval;',tmp.SubindexedValues(qq).ATTRIBUTE.index));
              end; end;
            end;
          end;
        end; end;
      end; end;
  return;
end;

frameItems={'absoluteTime','relativeTime','index','label',...
            'FramePeriod','linesPerFrame','pixelsPerFrame','scanLinePeriod'};
sharedItems={'objectiveLens','objectiveLensNA','objectiveLensMag','binningMode',...
             'rastersPerFrame','framePeriod','scanlinePeriod','dwellTime','bitDepth',...
             'positionCurrent_XAxis','positionCurrent_YAxis','positionCurrent_ZAxis',...
             'zDevice','rotation','opticalZoom','micronsPerPixel_XAxis','micronsPerPixel_YAxis',...
             'laserPower_0','laserWavelength_0','linesPerFrame','pixelsPerLine','scanLinePeriod'};

% General
h.Date=a.ATTRIBUTE.date;
h.Notes=a.ATTRIBUTE.notes;
h.Ver=a.ATTRIBUTE.version;
if isnan(h.Ver), h.Ver='PV ver3 detected'; end;

% SystemConfiguration
for mm=1:length(a.SystemConfiguration.Lasers),
  eval(sprintf('h.PV_shared.Laser(mm).%s=a.SystemConfiguration.Lasers.Laser(mm).ATTRIBUTE.index;',a.SystemConfiguration.Lasers.Laser(mm).ATTRIBUTE.name));
end;

% Sequence
h.nCycles=length(a.Sequence);
for cc=1:length(a.Sequence),
  %h.Sequence(cc).Cycle=a.Sequence.ATTRIBUTE(cc).cycle;
  %h.Sequence(cc).Type=a.Sequence.ATTRIBUTE(cc).type;
  for mm=1:length(a.Sequence(cc).Frame),
    for nn=1:length(a.Sequence(cc).Frame(mm).File),
      h.FramesAll{mm,cc}.File(nn).Channel=a.Sequence(cc).Frame(mm).File(nn).ATTRIBUTE.channel;
      h.FramesAll{mm,cc}.File(nn).Filename=a.Sequence(cc).Frame(mm).File(nn).ATTRIBUTE.filename;
    end;
    h.FramesAll{mm,cc}.absoluteTime=a.Sequence(cc).Frame(mm).ATTRIBUTE.absoluteTime;
    h.FramesAll{mm,cc}.relativeTime=a.Sequence(cc).Frame(mm).ATTRIBUTE.relativeTime;
    h.FramesAll{mm,cc}.index=a.Sequence(cc).Frame(mm).ATTRIBUTE.index;
    h.FramesAll{mm,cc}.label=a.Sequence(cc).Frame(mm).ATTRIBUTE.label;
    for nn=1:length(a.Sequence(cc).Frame(mm).PVStateShard.Key),
      eval(sprintf('h.FramesAll{mm,cc}.%s=a.Sequence(cc).Frame(mm).PVStateShard.Key(nn).ATTRIBUTE.value;',a.Sequence.Frame(mm).PVStateShard.Key(nn).ATTRIBUTE.key));
      if isfield(h.FramesAll{mm,cc},'positionCurrent_ZAxis'), h.FramesAll{mm,cc}.ZAxis=h.FramesAll{mm,cc}.positionCurrent_ZAxis; end;
    end;
  end;
end;

for mm=1:length(sharedItems),
    if isfield(h.FramesAll{1,1},sharedItems{mm}),
        disp(sprintf('  copying from Frame 1 to PV_shared  %s',sharedItems{mm}));
        eval(sprintf('h.PV_shared.%s=h.FramesAll{1,1}.%s;',sharedItems{mm},sharedItems{mm}));
    end;
end;
if isfield(h.PV_shared,'positionCurrent_XAxis'),
    h.PV_shared.positionCurrent{1}=h.PV_shared.positionCurrent_XAxis;
    h.PV_shared.positionCurrent{2}=h.PV_shared.positionCurrent_YAxis;
    h.PV_shared.positionCurrent{3}=h.PV_shared.positionCurrent_ZAxis;
end;
if isfield(h.PV_shared,'micronsPerPixel_XAxis'),
    h.PV_shared.micronsPerPixel{1}=h.PV_shared.micronsPerPixel_XAxis;
    h.PV_shared.micronsPerPixel{2}=h.PV_shared.micronsPerPixel_YAxis;
end;

if (config_flag),
  c=xml_read(cname);
else,
  c=[];
end;

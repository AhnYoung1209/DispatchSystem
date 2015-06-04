function JFrame = getJFrame(hfig)
narginchk(1,1);
if ~ishandle(hfig) && ~isequal(get(hfig,'Type'),'figure')
    error('The input argument must be a Figure handle.');
end
mde = com.mathworks.mde.desk.MLDesktop.getInstance;
if isequal(get(hfig,'NumberTitle'),'off') && isempty(get(hfig,'Name'))
    figTag = 'junziyang'; %Name the figure temporarily
    set(hfig,'Name',figTag);
elseif isequal(get(hfig,'NumberTitle'),'on') && isempty(get(hfig,'Name'))
    figTag = ['Figure ',num2str(hfig)];
elseif isequal(get(hfig,'NumberTitle'),'off') && ~isempty(get(hfig,'Name'))
    figTag = get(hfig,'Name');
else
    figTag = ['Figure ',num2str(hfig),': ',get(hfig,'Name')];
end
drawnow %Update figure window
jfig = mde.getClient(figTag); %Get the underlying JAVA object of the figure.
JFrame = jfig.getRootPane.getParent();
if isequal(get(hfig,'Name'),'junziyang')
    set(hfig,'Name',''); %Delete the temporary figure name
end
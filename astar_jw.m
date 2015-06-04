function varargout = astar_jw(varargin)
% astar_jw - A* implementation by Jeremy Wurbs
%
% This function is an implementation of the A star algorithm. It is meant 
% to be an implementation resource for you when trying to learn the A* 
% algorithm. To help you dissect this function, you can call astar_jw 
% without arguments to run the function in 'debug mode' (see below), and/or 
% run/examine the Matlab file robotSimulation.m to see how to use this 
% function with inputs.
%
% The calling form for this function can be one of the following:
% 1) Test the function
%     You may call the function without any arguments to see an example
%     implentation in debug mode (showing the search path as it is
%     searched). You may also call the function with a single argument
%     (a scalar) that selects a different test case, as follows:
%       1: Simple test case
%       2-3: Mazes
%       4: Straight shot (compare A* to a breadth first search algorithm)
%       5: Straight shot around obstacles
%       6: Diagonal search
%       7: Random large grid
%
%   Examples:
%       astar_jw();
%
%       testCase = 3;
%       astar_jw(testCase)
%
% 2) Standard function call
%     The general calling form for the function is as follows:
%
%      [path, directions] = astar_jw(grid, init, goal);
%
%   where the inputs are:
%       grid - a binary matrix where 0s are admissable movement locations
%                and 1s are untraversable locations.
%       init - a tuple of the search start location; in the form [y x]
%       goal - a tuple of the goal location; in the form [y x]
%
%   and the outpus are:
%       path - a list of the coordinates to go from the starting location
%               to the goal location; path is an (N+1)x2 matrix where N is 
%               the number of steps required to reach the goal; each row in
%               path is a [y x] tuple giving a grid coordinate location
%       directions - a list of the directions needed to reach the goal;
%               directions is an Nx2 matrix; instead of giving the 
%               coordinates for the optimal path (like the path matrix), 
%               the directions matrix gives the movements in the form 
%               [del_y del_x].
%   
%   The three inputs are all required (unless one is doing one of the test
%   cases) while the number of outputs may be 0, 1, or 2. If one output is
%   requested the path is returned. Refer to the file robotSimulation.m for
%   a simple example of how to use astar_jw with inputs.


    if nargin == 0 % Test case, use testCase=2 (Maze) by default  

        selectedGrid = 2;
        [grid, init, goal] = defineGrid(selectedGrid);

        % Whether or not to display debug info
        printDebugInfo = true;

    elseif nargin == 1 % Test case, set testCase to the input

        selectedGrid = varargin{1};
        [grid, init, goal] = defineGrid(selectedGrid);

        % Whether or not to display debug info
        printDebugInfo = true;

    elseif nargin == 3 % Function call with inputs

        grid = varargin{1};
        init = varargin{2};
        goal = varargin{3};

        printDebugInfo = false;

    end
    
    % Define all possible moves
    delta = [[-1  0]
             [ 0 -1]
             [ 1  0]
             [ 0  1]];
         
    % Add g & f terms to init if necessary
    if length(init)==2
        init(3) = 0;    % g
        init(4) = inf;  % f
    end
    
    % Perform search
    [path, directions] = search(grid, init, goal, delta, printDebugInfo);
    
    if nargout==1
        varargout{1} = path;
    elseif nargout==2
        varargout{1} = path;
        varargout{2} = directions;
    end
        

end

function [path, directions] = search(grid, init, goal, delta, printDebugInfo)
    % This function implements the A* algorithm

    % Initialize the open, closed and path lists
    open = []; closed = []; path = [];
    open = addRow(open, init);
    
    % Initialize directions list
    directions = [];
    
    % Initialize expansion timing grid
    expanded = -1 * ones(size(grid));
    expanded(open(1), open(2)) = 0;
    
    % Compute the heuristic measurement, h
    h = computeHeuristic(grid, goal, 'euclidean');  
    
    % Open window for graphical debug display if desired
    if printDebugInfo; fig = figure; end
    
    % Keep searching through the grid until the goal is found
    goalFound = false;
    while size(open,1)>0 && ~goalFound
        [open, closed, expanded] = expand(grid, open, closed, delta, expanded, h);
        
        % Display debug info if desired
        if printDebugInfo
            displayDebugInfo(grid, init, goal, open, closed, fig);    
        end
        
        goalFound = checkForGoal(closed, goal);
    end
    
    % If the goal was found lets get the optimal path
    if goalFound
        % We step from the goal to the start location. At each step we 
        % select the neighbor with the lowest 'expanded' value and add that
        % neighbor to the path list.
        path = goal;
        
        % Check to see if the start location is on the path list yet
        [~, indx] = ismember(init(1:2), path(:,1:2), 'rows');
        while ~indx
            
            % Use our findNeighbors function to find the neighbors of the
            % last location on the path list
            neighbors = findNeighbors(grid, path, size(path,1), delta);
            
            % Look at the expanded value of all the neighbors, add the one
            % with the lowest expanded value to the path
            expandedVal = expanded(goal(1),goal(2));
            for R = 1:size(neighbors,1)
                 neighborExpandedVal = expanded(neighbors(R,1), neighbors(R,2));
                 if neighborExpandedVal<expandedVal && neighborExpandedVal>=0
                     chosenNeighbor = R;
                     expandedVal = expanded(neighbors(R,1), neighbors(R,2));
                 end
            end
            path(end+1,:) = neighbors(chosenNeighbor,:);
            
            % Check to see if the start location has been added to the path
            % list yet
            [~, indx] = ismember(init(1:2), path(:,1:2), 'rows');
        end
        
        % Reorder the list to go from the starting location to the end loc
        path = flipud(path);
        
        % Compute the directions from the path
        directions = zeros(size(path)-[1 0]);
        for R = 1:size(directions,1)
            directions(R,:) =  path(R+1,:) - path(R,:);
        end
        
    end
    
    % Display results
    if printDebugInfo
        home
        if goalFound
            disp(['Goal Found! Distance to goal: ' num2str(closed(goalFound,3))])
            disp(' ')
            disp('Path: ')
            disp(path)

            fig = figure;
            displayPath(grid, path, fig)
        else
            disp('Goal not found!')
        end
    
        disp(' ')
        disp('Expanded: ')
        disp(expanded)
        disp(' ')
        disp([' Search time to target: ' num2str(expanded(goal(1),goal(2)))])
    end
   
end

function A = deleteRows(A, rows)
% The following way to delete rows was taken from the mathworks website
% that compared multiple ways to do it. The following appeared to be the
% fastest.
    index = true(1, size(A,1));
    index(rows) = false;
    A = A(index, :);
end

function A = addRow(A, row)
    A(end+1,:) = row;
end

function [open, closed, expanded] = expand(grid, open, closed, delta, expanded, h)
% This function expands the open list by taking the coordinate (row) with 
% the smallest f value (path cost) and adds its neighbors to the open list.

    % Expand the row with the lowest f
    row = find(open(:,4)==min(open(:,4)),1);
    
    % Edit the 'expanded' matrix to note the time in which the current grid
    % point was expanded
    expanded(open(row,1),open(row,2)) = max(expanded(:))+1;

    % Find all the neighbors (potential moves) from the chosen spot
    neighbors = findNeighbors(grid, open, row, delta);
    
    % Remove any neighbors that are already on the open or closed lists
    neighbors = removeListedNeighbors(neighbors, open, closed);

    % Add the neighbors still left to the open list
    for R = 1:size(neighbors,1)
        g = open(row,3)+1;
        f = g + h(neighbors(R,1),neighbors(R,2));
        open = addRow(open, [neighbors(R,:) g f] ); 
    end
    
    % Remove the row we just expanded from the open list and add it to the
    % closed list
    closed(end+1,:) = open(row,:);
    open = deleteRows(open, row);
end

function h = computeHeuristic(varargin)
% This function is used to compute the distance heuristic, h. By default
% this function computes the Euclidean distance from each grid space to the
% goal. The calling sequence for this function is as follows:
%   h = computeHeuristic(grid, goal[, distanceType])
%       where distanceType may be one of the following:
%           'euclidean' (default value)
%           'city-block'
%           'empty' (returns all zeros for heuristic function)

grid = varargin{1};
goal = varargin{2};

if nargin==3
    distanceType = varargin{3};
else
    distanceType = 'euclidean';
end

[m n] = size(grid);
[x y] = meshgrid(1:n,1:m);

if strcmp(distanceType, 'euclidean')
    h = sqrt((x-goal(2)).^2 + (y-goal(1)).^2); 
elseif strcmp(distanceType, 'city-block')
    h = abs(x-goal(2)) + abs(y-goal(1));
elseif strcmp(distanceType, 'empty')
    h = zeros(m,n);
else
    warning('Unknown distanceType for determining heuristic, h!')
    h = [];
end
    
end

function neighbors = findNeighbors(grid, open, row, delta)
% This function takes the desired row in the open list to expand and finds
% all potential neighbors (neighbors reachable through legal moves, as
% defined in the delta list).

    % Find the borders to the grid
    borders = size(grid);
    borders = [1 borders(2) 1 borders(1)]; % [xMin xMax yMin yMax] 

    % Initialize the current location and neighbors list
    cenSq = open(row,1:2);
    neighbors = [];

    % Go through all the possible moves (given in the 'delta' matrix) and
    % add moves not on the closed list
    for R = 1:size(delta,1)
        potMove = cenSq + delta(R,:);

        if potMove(1)>=borders(3) && potMove(1)<=borders(4) ...
                && potMove(2)>=borders(1) && potMove(2)<=borders(2)
            if grid(potMove(1), potMove(2))==0
                neighbors(end+1,:) = potMove; 
            end
        end
    end
    
end

function neighbors = removeListedNeighbors(neighbors, open, closed)
% This function removes any neighbors that are on the open or closed lists

    % Check to make sure there's anything even on the closed list
    if size(closed,1)==0
        return
    end
    
    % Find any neighbors that are on the open or closed lists
    rowsToRemove = [];
    for R = 1:size(neighbors)
        % Check to see if the neighbor is on the open list
        [~, indx] = ismember(neighbors(R,:),open(:,1:2),'rows');
        if indx>0
            rowsToRemove(end+1) = R;
        else
            % If the neighbor isn't on the open list, check to make sure it
            % also isn't on the closed list
            [~, indx] = ismember(neighbors(R,:),closed(:,1:2),'rows');
            if indx>0
                rowsToRemove(end+1) = R;
            end
        end
    end

    % Remove neighbors that were on either the open or closed lists
    if numel(rowsToRemove>0)
        neighbors = deleteRows(neighbors, rowsToRemove);
    end
end

function goalRow = checkForGoal(closed, goal)
% This function looks for the final goal destination on the closed list.
% Note, you could check the open list instead (and find the goal faster);
% however, we want to have a chance to expand the goal location itself, so
% we wait until it is on the closed list.
    [~, goalRow] = ismember(goal, closed(:,1:2), 'rows');
end

function displayDebugInfo(grid, init, goal, open, closed, h)
% Display the open and closed lists in the command window, and display an
% image of the current search of the grid.
    home
    disp('Open: ')
    disp(open)
    disp(' ')
    disp('Closed: ')
    disp(closed)

    displaySearchStatus(grid, init, goal, open, closed, h)
    pause(0.05)
end

function displaySearchStatus(grid, init, goal, open, closed, h)
% This function displays a graphical grid and search status to make
% visualization easier.
    grid = double(~grid);
    grid(init(1),init(2)) = 0.66;
    grid(goal(1),goal(2)) = 0.33;

    figure(h)
    imagesc(grid); colormap(gray); axis square; axis off; hold on

    plot(open(:,2),   open(:,1),   'go', 'LineWidth', 2)
    plot(closed(:,2), closed(:,1), 'ro', 'LineWidth', 2)
    
    hold off
end

function displayPath(grid, path, h)
    grid = double(~grid);
    
    figure(h)
    imagesc(grid); colormap(gray); axis off; hold on
    title('Optimal Path', 'FontWeight', 'bold');
     
    plot(path(:,2),  path(:,1),   'co', 'LineWidth', 2)
    plot(path(1,2),  path(1,1),   'gs', 'LineWidth', 4)
    plot(path(end,2),path(end,1), 'rs', 'LineWidth', 4)

end

function [grid, init, goal] = defineGrid(selectedGrid)

    switch selectedGrid
        case 1 % Simple test case
            grid = [[0 0 1 0 0 0]
                    [0 0 1 0 0 0]
                    [0 0 0 0 1 0]
                    [0 0 1 1 1 0]
                    [0 0 0 0 1 0]];
            init = [1 1 0 inf]; % [y x g f]
            goal = size(grid);
        case 2 % Maze
            grid = [[0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 1 1 1 1 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 1 0]
                    [1 1 0 1 1 1 1 1 1 1 1 1 0 0 0 1 1 1 1 1 0]
                    [0 0 0 0 1 0 0 0 1 0 0 0 0 1 1 1 0 0 0 0 0]
                    [0 1 1 0 1 0 1 0 1 0 1 1 1 1 0 0 0 1 1 1 1]
                    [0 1 0 0 0 0 1 0 1 0 1 0 0 0 0 1 0 0 0 0 0]
                    [0 1 0 1 1 0 1 0 0 0 1 0 1 0 1 1 0 1 0 1 0]
                    [0 1 0 1 0 1 1 1 1 1 1 0 1 1 1 0 0 1 0 1 0]
                    [0 1 0 1 0 1 0 0 0 0 0 0 1 0 0 0 0 1 0 1 0]
                    [0 0 0 0 0 1 0 1 1 1 1 1 1 0 1 1 1 1 1 1 0]
                    [0 1 1 1 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0]
                    [0 1 0 1 0 1 0 1 1 1 1 1 1 1 1 0 1 1 0 1 1]
                    [0 1 0 1 0 1 0 0 0 0 0 0 0 0 1 0 0 0 0 1 0]
                    [0 1 0 1 0 1 1 0 1 0 1 1 1 0 1 1 1 1 0 1 0]
                    [1 1 0 0 0 1 0 0 1 1 1 1 0 0 0 0 0 0 0 1 0]
                    [0 1 0 1 0 1 0 1 1 0 0 0 0 1 1 1 1 1 1 1 0]
                    [0 0 0 1 0 1 0 0 0 0 1 1 0 1 0 0 0 0 0 0 0]
                    [1 1 0 1 0 1 0 1 1 1 1 1 1 1 0 1 1 1 1 1 1]
                    [0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]];
            init = [17 1 0 inf]; % [y x g f]
            goal = [14 21];
            
        case 3 % Maze 2
            % Set up the simulated world
            grid = [[0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0]
                     [0 1 1 1 1 1 1 1 0 1 0 1 1 1 1 1 0 1 1 1 0 1 0 1 0]
                     [0 1 0 0 0 0 0 1 0 1 0 1 0 1 0 1 0 1 0 0 0 1 0 1 0]
                     [0 1 0 1 1 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 1 1 0 1 0]
                     [0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 1 0 0 0 1 0]
                     [0 1 0 1 0 0 0 1 0 1 0 0 0 1 0 1 0 1 0 1 0 1 0 1 0]
                     [0 1 0 1 1 1 1 1 0 1 0 1 1 1 0 0 0 0 0 1 0 1 0 1 0]
                     [0 1 0 0 0 0 0 0 0 1 0 0 1 0 0 1 1 1 1 1 0 1 1 1 0]
                     [0 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 0 0 0 1 0 1 0 0 0]
                     [0 0 0 0 0 0 0 1 0 0 0 0 1 0 1 0 0 1 0 1 0 1 0 1 0]
                     [1 1 0 1 1 1 0 1 0 1 1 1 1 0 1 0 1 1 0 1 0 1 0 1 0]
                     [0 1 0 1 0 0 0 1 0 1 0 1 0 0 0 0 1 0 0 1 1 1 0 1 0]
                     [0 1 0 1 1 1 0 1 0 1 0 0 0 1 1 1 1 0 1 1 0 0 0 1 0]
                     [0 1 0 0 0 1 1 1 0 1 1 0 1 1 0 0 1 0 1 0 0 1 1 1 1]
                     [0 1 1 1 0 0 0 0 0 0 1 0 1 0 0 1 1 0 1 0 1 1 0 0 0]
                     [0 0 0 1 0 1 1 1 1 0 1 0 1 1 0 0 0 0 0 0 1 0 0 1 0]
                     [1 1 0 1 0 1 0 0 0 0 1 0 0 1 1 1 1 0 1 0 1 0 1 1 0]
                     [0 0 0 1 0 1 0 1 1 1 1 1 0 0 0 0 0 0 0 0 1 0 1 0 0]
                     [0 1 1 1 0 1 0 1 0 0 0 1 0 1 0 1 1 1 1 1 1 0 1 0 1]
                     [0 0 0 0 0 1 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 1 0 0]];
            init = [20 25 0 inf]; % [y x g f]
            goal = [5 5];
            
        case 4 % Straight shot
            grid = [[0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]];
            init = [10 1 0 inf]; % [y x g f]
            goal = [10 21];
            
        case 5 % Staight shot around obstacles
            grid = [[0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]
                    [0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0]];
            init = [1 1 0 inf]; % [y x g f]
            goal = [1 21];
            
        case 6 % Diagonal search
            grid = zeros(20,21);
            init = [1 1 0 inf]; % [y x g f]
            goal = [20 21];
            
        case 7 % Random large grid
            grid = randi(5, [50 50]);
            grid(grid>1) = 0;
            
            init = [5 5 0 inf]; % [y x g f]
            goal = [45 45];
            
            grid(init(1), init(2)) = 0;
            grid(goal(1), goal(2)) = 0;
            
            
    end



end


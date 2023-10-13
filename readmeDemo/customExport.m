classdef customExport < titta2delim
    %{
    Demo class for customization of titta data.

    This class inherits from titta2delim.

    This class assumes that the data contains the following fields:
    - tittaData.expt.winRect : wRect from Psychtoolbox [X0 Y0 X1 Y1]

    We will add the following fields as a user defined action:
    - sessionInfo.window size : wRect from Psychtoolbox [X0 Y0 X1 Y1]
    - timeSeries.left gaze in pixel x : left eye gaze in display pixel x
    - timeSeries.left gaze in pixel y : left eye gaze in display pixel y
    - timeSeries.right gaze in pixel x : right eye gaze in display pixel x
    - timeSeries.right gaze in pixel y : right eye gaze in display pixel y
    
    %}

    methods

        function obj = customExport(varargin)
            %{
            Constructor for customExport class.
            %}
            obj = obj@titta2delim(varargin{:});
        end
    
        function obj = addUserDefinedSessionInfo(obj)
            %{
            Add any user defined session info here.
            This will be called at the end of sessionInfo().
            %}
            obj.addWindowSize();
        end


        function obj = addUserDefinedTimeSeries(obj)
            %{
            Add any user defined time series here.
            This will be called at the end of timeSeries().
            %}
            obj.addLeftGazeInPixelX();
            obj.addLeftGazeInPixelY();
            obj.addRightGazeInPixelX();
            obj.addRightGazeInPixelY();
        end


        function obj = userDefinedMain(obj)
            %{
            Add any user defined actions for main here.
            This will be called at the end of main().
            %}
            % TODO: change all NaN to empty cells
        end


        function obj = addWindowSize(obj, fieldName)
            % psychtoolbox window rect is saved in tittaData.expt.winRect
            % depends on the data
            defaultName = "window size";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.expt.winRect');
        end


        function obj = addLeftGazeInPixelX(obj, fieldName)
            % left eye gaze in display pixel x
            % range of gazePoint.onDisplayArea is [0, 1]
            % multiply by window size to get pixel
            defaultName = "left gaze in pixel x";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.onDisplayArea(1, :)' * obj.tittaData.expt.winRect(3));
        end


        function obj = addLeftGazeInPixelY(obj, fieldName)
            % left eye gaze in display pixel y
            % range of gazePoint.onDisplayArea is [0, 1]
            % multiply by window size to get pixel
            defaultName = "left gaze in pixel y";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.onDisplayArea(2, :)' * obj.tittaData.expt.winRect(4));
        end


        function obj = addRightGazeInPixelX(obj, fieldName)
            % right eye gaze in display pixel x
            % range of gazePoint.onDisplayArea is [0, 1]
            % multiply by window size to get pixel
            defaultName = "right gaze in pixel x";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.onDisplayArea(1, :)' * obj.tittaData.expt.winRect(3));
        end


        function obj = addRightGazeInPixelY(obj, fieldName)
            % right eye gaze in display pixel y
            % range of gazePoint.onDisplayArea is [0, 1]
            % multiply by window size to get pixel
            defaultName = "right gaze in pixel y";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.onDisplayArea(2, :)' * obj.tittaData.expt.winRect(4));
        end
             
    end % methods
end % classdef
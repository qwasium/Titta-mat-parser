classdef customExport < titta2delim
    %{
    Demo class for customization of titta data.

    This class inherits from titta2delim.

    This class assumes that the data contains the following fields:
    - tittaData.expt.winRect : wRect from Psychtoolbox [X0 Y0 X1 Y1]

    We will add the following fields as a user defined action:
    - sessionInfo.window size : wRect from Psychtoolbox [X0 Y0 X1 Y1]
    - timeSeries.left gaze in pixel x     : left eye gaze in display pixel x
    - timeSeries.left gaze in pixel y     : left eye gaze in display pixel y
    - timeSeries.right gaze in pixel x    : right eye gaze in display pixel x
    - timeSeries.right gaze in pixel y    : right eye gaze in display pixel y
    - timeSeries.prior message            : prior message of given time stamp
    - timeSeries.post message             : post message of given time stamp
    - timeSeries.prior message time stamp : time stamp of prior message
    - timeSeries.post message time stamp  : time stamp of post message

    %}

    methods

        %% constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = customExport(varargin)
            %{
            Constructor for customExport class.
            %}
            obj = obj@titta2delim(varargin{:});
        end


        %% add user defined methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % These methods are defined in titta2delim.
        % You can overwrite them here to add your own functionality.

        function obj = addUserDefinedSessionInfo(obj)
            %{
            Add any user defined session info here.
            This will be called at the end of titta2delim.sessionInfo().
            %}
            obj.addWindowSize();
        end


        function obj = addUserDefinedTimeSeries(obj)
            %{
            Add any user defined time series here.
            This will be called at the end of titta2delim.timeSeries().
            %}
            obj.addLeftGazeInPixelX();
            obj.addLeftGazeInPixelY();
            obj.addRightGazeInPixelX();
            obj.addRightGazeInPixelY();
        end


        function obj = userDefinedMain(obj)
            %{
            Add any user defined actions for main here.
            This will be called at the end of titta2delim.main().
            %}
            obj.splitTimeSeriesWithMessages();
        end


        %% define user defined methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Define your own methods added in the above section here.

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


        function obj = splitTimeSeriesWithMessages(obj, fieldNamePriorMsg, fieldNamePostMsg, fieldNamePriorTime, fieldNamePostTime)
            % Split time series into messages in obj.tittaData.messages.
            % System time stamp is used.
            % Set new fields in obj.timeSeries:
            %   - obj.timeSeries.(fieldNamePriorMsg)  : prior message of given time stamp
            %   - obj.timeSeries.(fieldNamePostMsg)   : post message of given time stamp
            %   - obj.timeSeries.(fieldNamePriorTime) : time stamp of prior message
            %   - obj.timeSeries.(fieldNamePostTime)  : time stamp of post message
            defaultPriorMsg     = "prior message";
            defaultPostMsg      = "post message";
            defaultPriorMsgTime = "prior message timestamp";
            defaultPostMsgTime  = "post message timestamp";

            if nargin == 1
                fieldNamePriorMsg  = "";
                fieldNamePostMsg   = "";
                fieldNamePriorTime = "";
                fieldNamePostTime  = "";
            end

            % check and set field names
            [obj, fieldNamePriorMsg]  = obj.setFieldName(defaultPriorMsg, fieldNamePriorMsg);
            [obj, fieldNamePostMsg]   = obj.setFieldName(defaultPostMsg,  fieldNamePostMsg);
            [obj, fieldNamePriorTime] = obj.setFieldName(defaultPriorMsgTime, fieldNamePriorTime);
            [obj, fieldNamePostTime]  = obj.setFieldName(defaultPostMsgTime,  fieldNamePostTime);

            % initialize variables and vectors
            priorMsgCol  = cell(length(obj.tittaData.data.gaze.systemTimeStamp), 1);
            postMsgCol   = cell(length(obj.tittaData.data.gaze.systemTimeStamp), 1);
            priorTimeCol = zeros(length(obj.tittaData.data.gaze.systemTimeStamp), 1);
            postTimeCol  = zeros(length(obj.tittaData.data.gaze.systemTimeStamp), 1);
            priorMsgPos  = NaN;
            postMsgPos   = NaN;

            % loop through time series
            % if no message is found, NaN is set for timestamp and "" for message
            % I don't know if this is faster than doing a binary search every time
            firstFound = false; % flag to check if first message is after time stamp of time series
            for i = 1:length(obj.tittaData.data.gaze.systemTimeStamp)

                % check if first message is after time stamp of time series
                if ~firstFound
                    if cell2mat(obj.tittaData.messages(1, 1)) > obj.tittaData.data.gaze.systemTimeStamp(i)
                        priorMsgPos = NaN;
                        postMsgPos  = 1;
                        priorTimeCol(i) = NaN;
                        priorMsgCol{i}  = "";
                        postTimeCol(i)  = cell2mat(obj.tittaData.messages(postMsgPos, 1));
                        postMsgCol{i}   = cell2mat(obj.tittaData.messages(postMsgPos, 2));
                        continue
                    else
                        firstFound  = true;
                        priorMsgPos = 1;
                    end
                end

                % We assume that no two messages have the same time stamp.
                for j = priorMsgPos:length(obj.tittaData.messages)

                    % if we reach the last message handle it separately
                    if j == length(obj.tittaData.messages)
                        priorMsgPos = j;
                        postMsgPos  = NaN;
                        priorTimeCol(i) = cell2mat(obj.tittaData.messages(priorMsgPos, 1));
                        priorMsgCol{i}  = cell2mat(obj.tittaData.messages(priorMsgPos, 2));
                        postTimeCol(i)  = NaN;
                        postMsgCol{i}   = "";
                        break

                    % stop at first message that is after current time stamp and add to time series
                    elseif cell2mat(obj.tittaData.messages(j+1, 1)) > obj.tittaData.data.gaze.systemTimeStamp(i)
                        priorMsgPos = j;
                        postMsgPos  = j+1;
                        priorTimeCol(i) = cell2mat(obj.tittaData.messages(priorMsgPos, 1));
                        priorMsgCol{i}  = cell2mat(obj.tittaData.messages(priorMsgPos, 2));
                        postTimeCol(i)  = cell2mat(obj.tittaData.messages(postMsgPos, 1));
                        postMsgCol{i}   = cell2mat(obj.tittaData.messages(postMsgPos, 2));
                        break
                    end
                end % for j = priorMsgPos:length(obj.tittaData.messages)
            end % for i = 1:length(obj.tittaData.data.gaze.systemTimeStamp)

            % add data to obj.timeSeries
            obj.addToTimeSeries(fieldNamePriorTime, priorTimeCol);
            obj.addToTimeSeries(fieldNamePriorMsg, priorMsgCol);
            obj.addToTimeSeries(fieldNamePostTime, postTimeCol);
            obj.addToTimeSeries(fieldNamePostMsg, postMsgCol);

        end

    end % methods
end % classdef
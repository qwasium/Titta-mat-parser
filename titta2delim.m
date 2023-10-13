classdef titta2delim < handle
    %{

    Simon Kuwahara
    Oct2023
    MATLAB R2023a
    GNU/Octave 6.4.0
    Ubuntu 22.04
    
    Use inheritance/polymorphism to suit your needs.
    Depercated matlab functions are used for compatibility with GNU/Octave.

    To set custom header names for export data, create a dictionary where it is like:
        "default header name" -> "custom output name"
    "Default header names" are hard-coded names used only in this code 
    and are not official names used by Titta nor Tobii SDK.
        
    Example code:
        
        ```matlab
        
        % load titta output (shown as data.mat here)
        tittaMat = load('data.mat');

        % convert to table
        data = titta2delim(tittaMat);
        data.main();

        % write to csv
        writetable(data.sessionInfo, 'sesionInfo.csv');
        writetable(data.timeSeries, 'timeSeries.csv');
        writetable(data.messages, 'messages.csv');
        writetable(data.TobiiLog, 'TobiiLog.csv');
        writetable(data.notifications, 'notifications.csv');
                
        ```

    %}

    properties

        tittaData % struct % structure of Titta output
        
        % table in MATLAB, struct in GNU/Octave. All values must be cell.
        timeSeries    % Time series data.
        sessionInfo   % Measurement settings data.
        messages      % tittaData.messages
        TobiiLog      % tittaData.TobiiLog
        notifications % tittaData.data.notifications
        % calibration   % Not implemented

        tableLen % struct                 % length of each table/struct
        keyMap   % containers.Map OR dict % header name: default name -> output name
        isOctave % bool                   % true if GNU/Octave, false if MATLAB
    
    end



    methods

        function obj = titta2delim(tittaData, keyMap)
            %{
            
            Constructor method.

            Parameters
            ----------
            tittaData : struct
                Structure of data. Output of Titta.
            keyMap : (optional) containers.Map or dictionary
                Header name key map. If not provided, default is used.
                If dictionary, type must be string -> string.
                Read header comments for more information.
            
            %}
            if nargin == 2
                addKeyMap(obj, keyMap)
            end
            obj.tittaData = tittaData;

            % check if MATLAB or GNU/Octave
            obj.isOctave = exist('OCTAVE_VERSION', 'builtin')~=0;

            % initialize tables length
            obj.tableLen.sessionInfo   = 1;
            obj.tableLen.timeSeries    = 1;
            obj.tableLen.messages      = 1;
            obj.tableLen.TobiiLog      = 1;
            obj.tableLen.notifications = 1;

            % set to tables if matlab
            if ~obj.isOctave
                obj.timeSeries    = table;
                obj.sessionInfo   = table;
                obj.messages      = table;
                obj.TobiiLog      = table;
                obj.notifications = table;
            end
        end

        
        function obj = addKeyMap(obj, keyMap)
            %{
            
            add field name key map to property

            Parameters
            ----------
            keyMap : containers.Map or dictionary
                Header name key map. If not provided, default is used.
                If dictionary, type must be string -> string.
                Read header comments for more information.

            %}
            if obj.validateKeyMap(keyMap)
                if ~isempty(obj.keyMap)
                    warning('Overwriting existing header name with provided one.');
                end
                obj.keyMap = keyMap;
            else
                if isempty(obj.keyMap)
                    warning('Provided header name is invalid. Using default.');
                else
                    warning('Provided header name is invalid. Existing header name will NOT be modified.');
                end
            end
        end


        %% main ---------------------------------------------------------

        function obj = main(obj)
            % main
            obj.createSessionInfo();
            obj.createTimeSeries();
            obj.createLog();
            % obj.createCalibration(); % not implemented
            obj.userDefinedMain();
        end


        function obj = createSessionInfo(obj)
            
            % ran date
            obj.addExportDate();

            
            % tittaData.settings
            obj.addEyeTracker();
            obj.addTrackingMode();
            % serial number: tittaData.systemInfo
            obj.addFrequency();
            obj.addCalibrateEye();
            obj.addLicenseFile();
            obj.addReconnectionAttempts();
            obj.addConnectRetryWait();
            % UI    : not implemented
            % cal   : not implemented
            % val   : not implemented
            % mancal: not implemented
            obj.addDebugMode();

            
            % tittaData.systemInfo
            obj.addDeviceName();
            obj.addSerialNumber();
            obj.addModel();
            obj.addFirmwareVersion();
            obj.addRuntimeVersion();
            obj.addAddress();
            % frequency   : tittaData.settings
            % trackingMode: tittaData.settings
            obj.addCapabilities();
            obj.addSupportedFrequencies();
            obj.addSupportedModes();
            obj.addSDKVersion();

            
            % tittaData.geometry.displayArea
            obj.addDisplayAreaHeight();
            obj.addDisplayAreaWidth();
            obj.addDisplayAreaBottomLeft();
            obj.addDisplayAreaBottomRight();
            obj.addDisplayAreaTopLeft();
            obj.addDisplayAreaTopRight();

            
            % tittaData.geometry.trackBox
            obj.addTrackBoxBackLowerLeft();
            obj.addTrackBoxBackLowerRight();
            obj.addTrackBoxBackUpperLeft();
            obj.addTrackBoxBackUpperRight();
            obj.addTrackBoxFrontLowerLeft();
            obj.addTrackBoxFrontLowerRight();
            obj.addTrackBoxFrontUpperLeft();
            obj.addTrackBoxFrontUpperRight();
            obj.addTrackBoxHalfWidth();
            obj.addTrackBoxHalfHeight();


            % user defined
            obj.addUserDefinedSessionInfo();
        end


        function obj = createTimeSeries(obj)
            
            % tittaData.data.gaze
            obj.addDeviceTimeStamp();
            obj.addSystemTimeStamp();
            obj.addLeftGazeValidity();
            obj.addRightGazeValidity();
            obj.addLeftGazeOnDisplayAreaX();
            obj.addLeftGazeOnDisplayAreaY();
            obj.addRightGazeOnDisplayAreaX();
            obj.addRightGazeOnDisplayAreaY();
            obj.addLeftGazeInUserCoordsX();
            obj.addLeftGazeInUserCoordsY();
            obj.addLeftGazeInUserCoordsZ();
            obj.addRightGazeInUserCoordsX();
            obj.addRightGazeInUserCoordsY();
            obj.addRightGazeInUserCoordsZ();
            obj.addLeftPupilValidity();
            obj.addRightPupilValidity();
            obj.addLeftPupilDiameter();
            obj.addRightPupilDiameter();
            obj.addLeftGazeOriginValidity();
            obj.addRightGazeOriginValidity();
            obj.addLeftGazeOriginInUserCoordsX();
            obj.addLeftGazeOriginInUserCoordsY();
            obj.addLeftGazeOriginInUserCoordsZ();
            obj.addRightGazeOriginInUserCoordsX();
            obj.addRightGazeOriginInUserCoordsY();
            obj.addRightGazeOriginInUserCoordsZ();
            obj.addLeftGazeOriginInTrackBoxCoordsX();
            obj.addLeftGazeOriginInTrackBoxCoordsY();
            obj.addLeftGazeOriginInTrackBoxCoordsZ();
            obj.addRightGazeOriginInTrackBoxCoordsX();
            obj.addRightGazeOriginInTrackBoxCoordsY();
            obj.addRightGazeOriginInTrackBoxCoordsZ();

            
            % tittaData.data.eyeImages
            % Not implemented

            
            % tittaData.data.externalSignals
            % Not implemented

            
            % tittaData.data.timeSync
            % Not implemented
            
            
            % user defined
            obj.addUserDefinedTimeSeries();
        end


        function obj = createLog(obj)

            % tittaData.messages
            obj.addMessagesTimestamp();
            obj.addMessagesMessage();

            
            % tittaData.TobiiLog
            if ~obj.isOctave
                obj.TobiiLog = struct2table(obj.tittaData.TobiiLog);
            else
                obj.TobiiLog = obj.tittaData.TobiiLog;
            end

            % tittaData.data.notifications
            if ~obj.isOctave
                obj.notifications = struct2table(obj.tittaData.data.notifications);
            else
                obj.notifications = obj.tittaData.data.notifications;
            end

            
        end


        function obj = createCalibration(obj)
            %{
            Not implemented
            %}
        end


        function obj = userDefinedMain(obj)
            %{
            Add any user defined actions for main here.
            This will be called at the end of main().
            %}
        end


        %% session info -------------------------------------------------
        %{
        SessionInfo is a table of measurement settings.

        All functions except for addSessionInfo() are used to add data to sessionInfo table.
        The following discription of the argument fieldName is applicable to all functions except for addUserDefinedSessionInfo().
        
        Parameters
        ----------
        fieldName : (optional) char or string
            Provided field name. 
            If provided, it will override keyMap and default.
            Priority is as follows:
                1. provided field name
                2. keyMap
                3. default        

        %}
        
        
        function obj = addUserDefinedSessionInfo(obj)
            %{
            Add any user defined actions for sessionInfo here.
            This will be called at the end of createSessionInfo() which is called by main().
            %}
        end


        function obj = addExportDate(obj, fieldName)
            % export date: YYYY-MM-DD
            % example: [2021-09-23]
            defaultName = "export date";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            if obj.isOctave
                obj.addToSessionInfo(fieldName, datestr(now(), 29));
            else
                obj.addToSessionInfo(fieldName, datetime('today', 'Format', 'yyyy-MM-dd'));
            end
        end

        
        function obj = addEyeTracker(obj, fieldName)
            % eye tracker model 
            % example: 'Tobii Pro Spectrum'
            defaultName = "eyetracker";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName,obj.tittaData.settings.tracker);
        end


        function obj = addTrackingMode(obj, fieldName)
            % eye tracking mode 
            % example: 'human'
            defaultName = "mode";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName,obj.tittaData.settings.trackingMode);
            % obj.addToSessionInfo(fieldName,obj.tittaData.systemInfo.trackingMode);
        end

        
        function obj = addFrequency(obj, fieldName)
            % sampling frequency
            % example: [1200]
            defaultName = "sampling frequency";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName,obj.tittaData.settings.freq);
            % obj.addToSessionInfo(fieldName,obj.tittaData.systemInfo.frequency);
        end
        

        function obj = addCalibrateEye(obj, fieldName)
            % calibrated eye
            % example: 'both'
            defaultName = "calibrated eye";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.settings.calibrateEye);
        end


        function obj = addLicenseFile(obj, fieldName)
            % license file
            defaultName = "license file";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.settings.licenseFile);
        end
        

        function obj = addReconnectionAttempts(obj, fieldName)
            % reconnection attempts
            % example: [3]
            defaultName = "reconnection attemts";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.settings.nTryReConnect);
        end


        function obj = addConnectRetryWait(obj, fieldName)
            % reconnection wait
            % example: [1, 2]
            defaultName = "reconnection wait";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.settings.connectRetryWait');
        end


        function obj = addDebugMode(obj, fieldName)
            % debug mode, defined by Titta
            % example: [1]
            defaultName = "debug mode";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.settings.debugMode);
        end


        function obj = addDeviceName(obj, fieldName)
            % device name
            % example: 'TS-001-000000000000'
            defaultName = "device name";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.deviceName);
        end


        function obj = addSerialNumber(obj, fieldName)
            % serial number
            % example: 'TSP-001-000000000000'
            defaultName = "serial number";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.serialNumber);
        end


        function obj = addModel(obj, fieldName)
            % eye tracker model
            % example: 'Tobii Pro Spectrum'
            defaultName = "model";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.model);
        end


        function obj = addFirmwareVersion(obj, fieldName)
            % firmware version
            % example: '1.0.0'
            defaultName = "firmware version";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.firmwareVersion);
        end


        function obj = addRuntimeVersion(obj, fieldName)
            % runtime version
            % example: '1.0.0'
            defaultName = "runtime version";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.runtimeVersion);
        end
        

        function obj = addAddress(obj, fieldName)
            % connection address
            % example: 'tet-tcp://169.254.0.1'
            defaultName = "connection address";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.address);
        end


        function obj = addCapabilities(obj, fieldName)
            % list of available functions
            % example: 'CanSetDisplayArea'
            defaultName = "capabilities";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.capabilities);
        end


        function obj = addSupportedFrequencies(obj, fieldName)
            % list of available frequencies
            % example: [1200; 600; 300; 120; 60]
            defaultName = "supported frequencies";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.supportedFrequencies);
        end


        function obj = addSupportedModes(obj, fieldName)
            % list of available tracking modes
            % example: 'human'
            defaultName = "supported modes";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.supportedModes);
        end


        function obj = addSDKVersion(obj, fieldName)
            % Tobii SDK version
            % example: '1.0.0'
            defaultName = "SDK version";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.systemInfo.SDKVersion);
        end


        function obj = addDisplayAreaHeight(obj, fieldName)
            % display area height
            % example: [312.54]
            defaultName = "display area height";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.displayArea.height);
        end


        function obj = addDisplayAreaWidth(obj, fieldName)
            % display area width
            % example: [312.54]
            defaultName = "display area width";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.displayArea.width);
        end


        function obj = addDisplayAreaBottomLeft(obj, fieldName)
            % display area bottom left: [x, y, z]
            defaultName = "display area bottom left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName,obj.tittaData.geometry.displayArea.bottomLeft);
        end

        
        function obj = addDisplayAreaBottomRight(obj, fieldName)
            % display area bottom right: [x, y, z]
            defaultName = "display area bottom right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.displayArea.bottomRight);
        end


        function obj = addDisplayAreaTopLeft(obj, fieldName)
            % display area top left: [x, y, z]
            defaultName = "display area top left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.displayArea.topLeft);
        end


        function obj = addDisplayAreaTopRight(obj, fieldName)
            % display area top right: [x, y, z]
            defaultName = "display area top right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.displayArea.topRight);
        end


        function obj = addTrackBoxBackLowerLeft(obj, fieldName)
            % track box back lower left: [x, y, z]
            defaultName = "track box back lower left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.backLowerLeft);
        end


        function obj = addTrackBoxBackLowerRight(obj, fieldName)
            % track box back lower right: [x, y, z]
            defaultName = "track box back lower right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.backLowerRight);
        end


        function obj = addTrackBoxBackUpperLeft(obj, fieldName)
            % track box back upper left: [x, y, z]
            defaultName = "track box back upper left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.backUpperLeft);
        end


        function obj = addTrackBoxBackUpperRight(obj, fieldName)
            % track box back upper right: [x, y, z]
            defaultName = "track box back upper right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.backUpperRight);
        end


        function obj = addTrackBoxFrontLowerLeft(obj, fieldName)
            % track box front lower left: [x, y, z]
            defaultName = "track box front lower left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.frontLowerLeft);
        end


        function obj = addTrackBoxFrontLowerRight(obj, fieldName)
            % track box front lower right: [x, y, z]
            defaultName = "track box front lower right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.frontLowerRight);
        end


        function obj = addTrackBoxFrontUpperLeft(obj, fieldName)
            % track box front upper left: [x, y, z]
            defaultName = "track box front upper left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.frontUpperLeft);
        end


        function obj = addTrackBoxFrontUpperRight(obj, fieldName)
            % track box front upper right: [x, y, z]
            defaultName = "track box front upper right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.frontUpperRight);
        end


        function obj = addTrackBoxHalfWidth(obj, fieldName)
            % track box half width
            % example: [0.5]
            defaultName = "track box half width";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.halfWidth);
        end


        function obj = addTrackBoxHalfHeight(obj, fieldName)
            % track box half height
            % example: [0.5]
            defaultName = "track box half height";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToSessionInfo(fieldName, obj.tittaData.geometry.trackBox.halfHeight);
        end


        %% time series --------------------------------------------------
        %{
        timeSeries is a table of time-series measurement data.

        All functions except for addTimeSeries() are used to add data to timeSeries table.
        The following discription of the argument fieldName is applicable to all functions except for addUserDefinedTimeSeries().
        
        Parameters
        ----------
        fieldName : (optional) char or string
            Provided field name. 
            If provided, it will override keyMap and default.
            Priority is as follows:
                1. provided field name
                2. keyMap
                3. default        

        %}


        function obj = addUserDefinedTimeSeries(obj)
            %{
            Add any user defined actions for timeSeries here.
            This will be called at the end of createTimeSeries() which is called by main().
            %}
        end


        function obj = addDeviceTimeStamp(obj, fieldName)
            % device time stamp
            defaultName = "Eyetracker timestamp";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.deviceTimeStamp);
        end
        

        function obj = addSystemTimeStamp(obj, fieldName)
            % system time stamp
            defaultName = "system timestamp";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.systemTimeStamp);
        end


        function obj = addLeftGazeValidity(obj, fieldName)
            % left gaze validity
            % valid: 1, invalid: 0
            defaultName = "Validity of gaze left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.valid);
        end


        function obj = addRightGazeValidity(obj, fieldName)
            % right gaze validity
            % valid: 1, invalid: 0
            defaultName = "Validity of gaze right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.valid);
        end


        function obj = addLeftGazeOnDisplayAreaX(obj, fieldName)
            % left gaze on display x
            % top-left: (x=0, y=0), bottom-right of: (x=1, y=1)
            defaultName = "Gaze point left X (adcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.onDisplayArea(1, :)');
        end
        

        function obj = addLeftGazeOnDisplayAreaY(obj, fieldName)
            % left gaze on display y
            % top-left: (x=0, y=0), bottom-right of: (x=1, y=1)
            defaultName = "Gaze point left Y (adcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.onDisplayArea(2, :)');
        end


        function obj = addRightGazeOnDisplayAreaX(obj, fieldName)
            % right gaze on display x
            % top-left: (x=0, y=0), bottom-right of: (x=1, y=1)
            defaultName = "Gaze point right X (adcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.onDisplayArea(1, :)');
        end


        function obj = addRightGazeOnDisplayAreaY(obj, fieldName)
            % right gaze on display y
            % top-left: (x=0, y=0), bottom-right of: (x=1, y=1)
            defaultName = "Gaze point right Y (adcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.onDisplayArea(2, :)');
        end


        function obj = addLeftGazeInUserCoordsX(obj, fieldName)
            % left gaze in user coordinates x
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze point left X (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.inUserCoords(1, :)');
        end


        function obj = addLeftGazeInUserCoordsY(obj, fieldName)
            % left gaze in user coordinates y
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze point left Y (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.inUserCoords(2, :)');
        end


        function obj = addLeftGazeInUserCoordsZ(obj, fieldName)
            % left gaze in user coordinates z
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze point left Z (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazePoint.inUserCoords(3, :)');
        end


        function obj = addRightGazeInUserCoordsX(obj, fieldName)
            % right gaze in user coordinates x
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze point right X (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);            
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.inUserCoords(1, :)');
        end


        function obj = addRightGazeInUserCoordsY(obj, fieldName)
            % right gaze in user coordinates y
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze point right Y (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.inUserCoords(2, :)');
        end


        function obj = addRightGazeInUserCoordsZ(obj, fieldName)
            % right gaze in user coordinates z
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze point right Z (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazePoint.inUserCoords(3, :)');
        end


        function obj = addLeftPupilValidity(obj, fieldName)
            % left pupil validity
            % valid: 1, invalid: 0
            defaultName = "Validity of pupil left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.pupil.valid);
        end


        function obj = addRightPupilValidity(obj, fieldName)
            % right pupil validity
            % valid: 1, invalid: 0
            defaultName = "Validity of pupil right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.pupil.valid);
        end


        function obj = addLeftPupilDiameter(obj, fieldName)
            % left pupil diameter
            % unit: mm
            defaultName = "Pupil diameter left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.pupil.diameter);
        end


        function obj = addRightPupilDiameter(obj, fieldName)
            % right pupil diameter
            % unit: mm
            defaultName = "Pupil diameter right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.pupil.diameter);
        end


        function obj = addLeftGazeOriginValidity(obj, fieldName)
            % left gaze origin validity
            % valid: 1, invalid: 0
            defaultName = "Validity of gaze origin left";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazeOrigin.valid);
        end


        function obj = addRightGazeOriginValidity(obj, fieldName)
            % right gaze origin validity
            % valid: 1, invalid: 0
            defaultName = "Validity of gaze origin right";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazeOrigin.valid);
        end


        function obj = addLeftGazeOriginInUserCoordsX(obj, fieldName)
            % left gaze origin in user coordinates x
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin left X (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazeOrigin.inUserCoords(1, :)');
        end


        function obj = addLeftGazeOriginInUserCoordsY(obj, fieldName)
            % left gaze origin in user coordinates y
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin left Y (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazeOrigin.inUserCoords(2, :)');
        end


        function obj = addLeftGazeOriginInUserCoordsZ(obj, fieldName)
            % left gaze origin in user coordinates z
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin left Z (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazeOrigin.inUserCoords(3, :)');
        end


        function obj = addRightGazeOriginInUserCoordsX(obj, fieldName)
            % right gaze origin in user coordinates x
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin right X (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazeOrigin.inUserCoords(1, :)');
        end


        function obj = addRightGazeOriginInUserCoordsY(obj, fieldName)
            % right gaze origin in user coordinates y
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin right Y (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazeOrigin.inUserCoords(2, :)');
        end


        function obj = addRightGazeOriginInUserCoordsZ(obj, fieldName)
            % right gaze origin in user coordinates z
            % eye tracker origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin right Z (ucs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazeOrigin.inUserCoords(3, :)');
        end


        function obj = addLeftGazeOriginInTrackBoxCoordsX(obj, fieldName)
            % left gaze origin in track box coordinates x
            % track box origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin left X (tbcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                        
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazeOrigin.inTrackBoxCoords(1, :)');
        end


        function obj = addLeftGazeOriginInTrackBoxCoordsY(obj, fieldName)
            % left gaze origin in track box coordinates y
            % track box origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin left Y (tbcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                                    
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazeOrigin.inTrackBoxCoords(2, :)');
        end


        function obj = addLeftGazeOriginInTrackBoxCoordsZ(obj, fieldName)
            % left gaze origin in track box coordinates z
            % track box origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin left Z (tbcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                                    
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.left.gazeOrigin.inTrackBoxCoords(3, :)');
        end


        function obj = addRightGazeOriginInTrackBoxCoordsX(obj, fieldName)
            % right gaze origin in track box coordinates x
            % track box origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin right X (tbcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                                    
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazeOrigin.inTrackBoxCoords(1, :)');
        end


        function obj = addRightGazeOriginInTrackBoxCoordsY(obj, fieldName)
            % right gaze origin in track box coordinates y
            % track box origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin right Y (tbcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                                    
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazeOrigin.inTrackBoxCoords(2, :)');
        end


        function obj = addRightGazeOriginInTrackBoxCoordsZ(obj, fieldName)
            % right gaze origin in track box coordinates z
            % track box origin: (x=0, y=0, z=0)
            defaultName = "Gaze origin right Z (tbcs)";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);                                    
            obj.addToTimeSeries(fieldName, obj.tittaData.data.gaze.right.gazeOrigin.inTrackBoxCoords(3, :)');
        end


        %% create log ---------------------------------------------------

        function obj = addMessagesTimestamp(obj, fieldName)
            % time stamp of messages in milliseconds
            % See Titta.getMessages() in Titta source code for more information.
            defaultName = "system timestamp";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToMessages(fieldName, obj.tittaData.messages(:, 1));
        end


        function obj = addMessagesMessage(obj, fieldName)
            % user defined messages
            defaultName = "message";
            if nargin == 1
                fieldName = "";
            end
            [obj, fieldName] = obj.setFieldName(defaultName, fieldName);
            obj.addToMessages(fieldName, obj.tittaData.messages(:, 2));
        end


        %% helper functions ---------------------------------------------
        

        function validity = validateKeyMap(~, testKeyMap)
            %{

            validate key map

            Parameters
            ----------
            testKeyMap : containers.Map or dictionary
                Header name key map. If not provided, default is used.
                If dictionary, type must be string -> string.
                Read header comments for more information.

            Returns
            -------
            validity : logical
                True if valid, false if not.

            %}
            validity   = false;
            keyIsTxt   = false;
            valueIsTxt = false;

            % check if containers.Map or dictionary and check key and value types
            if isa(testKeyMap, 'containers.Map')
                keyIsTxt   = all(testKeyMap.KeyType   == 'char') || all(testKeyMap.KeyType   == 'string') || all(iscellstr(testKeyMap.keys));
                valueIsTxt = all(testKeyMap.ValueType == 'char') || all(testKeyMap.ValueType == 'string') || all(iscellstr(testKeyMap.values));
            elseif isa(testKeyMap, 'dictionary')
                keyIsTxt   = all(isstring(testKeyMap.keys));
                valueIsTxt = all(isstring(testKeyMap.values));
            end
            if keyIsTxt && valueIsTxt
                validity = true;
            end    
        end

        function obj = addToSessionInfo(obj, fieldName, addData)
            %{
            Add data to sessionInfo table.
            See addToTable() for more information.
            %}
            obj.addToTable('sessionInfo', fieldName, addData);
        end

        function obj = addToTimeSeries(obj, fieldName, addData)
            %{
            Add data to timeSeries table.
            See addToTable() for more information.
            %}
            obj.addToTable('timeSeries', fieldName, addData);
        end

        function obj = addToMessages(obj, fieldName, addData)
            %{
            Add data to messages table.
            See addToTable() for more information.
            %}
            obj.addToTable('messages', fieldName, addData);
        end


        function obj = addToTable(obj, tableName, fieldName, addData)
            %{

            Add data to table.

            Parameters
            ----------
            tableName : char or string
                Name of table to add data to.
            fieldName : char or string
                The column name of the table of the data to be added.
                Note that keyMap is not referenced here and the column name will be set as provided.
                It is recommended to pass it through setFieldName() first.
            addData : (:, 1) cell or convertable to cell
                Data to add. Must be a column vector or cell array.
                If addData is a cell, it should not be nested.

            Returns
            -------
            obj : titta2delim
                titta2delim object.

            %}

            % if addData is a char, convert to cell string
            if ischar(addData)
                addData = cellstr(addData);
            end
            
            dataDim = size(addData);

            % if addData is a row vector, transpose
            if dataDim(2) ~= 1 && dataDim(1) == 1
                warning('Data must be a column vector. Transposing: %s', fieldName);
                addData  = addData';
                dataDim  = size(addData);
            end

            % if addData is not a row vector, skip
            if dataDim(2) ~= 1
                warning('Data dimension is invalid. Skipping: %s', fieldName);
                return
            end

            % if addData is a single cell check it is not nested
            if dataDim(1) == 1 && iscell(addData)
                [isGoodTxt, ~] = checkIfText(obj, "", addData{1});
                if isGoodTxt == false && ~all(size(addData{1}) == [1, 1]) % isGoodTxt is TRUE if addData{1} is empty
                    warning('Data probably ended up inside a single cell. Skipping: %s', fieldName);
                    return
                end
            end

            % if data is not a cell, convert to cell
            if ~iscell(addData)
                addData = num2cell(addData);
            end

            % if table size is not equal to data size, fill with empty cells
            diffLen = dataDim(1) - obj.tableLen.(tableName);
            if diffLen > 0 && ~isempty(obj.(tableName))
                % table > data

                if obj.isOctave
                    header = fieldnames(obj.(tableName));
                    for i = 1:numel(header)
                        fillDiff    = cell(diffLen, 1);
                        fillDiff(:) = {NaN};
                        obj.(tableName).(header{i}) = [obj.(tableName).(header{i}); fillDiff];
                    end
                else % matlab
                    fillDiff        = cell(diffLen, size(obj.(tableName), 2));
                    fillDiff(:)     = {NaN};
                    fillDiff        = array2table(fillDiff, "VariableNames", obj.(tableName).Properties.VariableNames);
                    obj.(tableName) = [obj.(tableName); fillDiff];
                end
                
            elseif diffLen < 0
                % table > data
                fillDiff    = cell(abs(diffLen), 1);
                fillDiff(:) = {NaN};
                addData     = [addData; fillDiff];
            end

            % update table length
            if diffLen > 0
                obj.tableLen.(tableName) = dataDim(1);
            end

            % add data
            obj.(tableName).(fieldName) = addData;
        end

        
        function [obj, fieldName] = setFieldName(obj, defaultName, fieldName)
            %{

            Set field name.
            If field name is not provided or invalid, default is used.


            Parameters
            ----------
            defaultName : string
                Default field name.
                This is hard-coded in this class.
                If keyMap is provided, defaultName will be set to keyMap value.
            fieldName : (optional) char or string
                Provided field name. 
                If provided and confirmed as valid, fieldName is returned as is.
                Read below Return section for more information.
            
            Returns
            -------
            obj : titta2delim
                titta2delim object.
            fieldName : char or string
                Field name to use. If argument fieldName is...
                    1. provided and valid   : fieldName is returned as is.
                    2. provided and invalid : it will fall back to keyMap or default.
                    3. not provided         : it will fall back to keyMap or default.
                Priority is as follows:
                    1. provided field name
                    2. keyMap
                    3. defaultName

            %}

            if nargin == 2
                fieldName = "";
            end

            % matlab char will not work when indexing key of dictionary
            if ischar(defaultName) && ~obj.isOctave
                defaultName = obj.string(defaultName);
            end

            % check if default name is in map
            % if default name is in map, set default name to map value
            if ~isempty(obj.keyMap)
                if isKey(obj.keyMap, defaultName)
                    defaultName = obj.keyMap(defaultName);
                end
            end
            
            % check if fieldName is valid
            [validity ,fieldName] = obj.checkIfText(defaultName, fieldName);
            if ~validity
                warning('Provided field name is invalid, setting to default: %s', fieldName);
            end
        end


        function [validity, returnName] = checkIfText(obj, defaultName, testThisName)
            %{
            
            check supplied text and if invalid, retun default name
            
            Parameters
            ----------
            defaultName : string
                Default return.
                If testThisName is invalid, returnName will be set to defaultName.
                Make sure that defaultName is valid.
            testThisName : char or string or cellstr
                Name to test. If valid, returnName will be set to testThisName.
            
            Returns
            -------
            validity : logical or NaN
                - TRUE  if testThisName is valid or empty/not provided
                - FALSE if testThisName is invalid
            returnName : char or string
                - tetThisName if testThisName is valid
                - defaultName if testThisName is invalid or not provided.

            %}
            % set default returns
            validity   = false;
            returnName = defaultName;
            
            % if testThisName is not provided return true
            if nargin == 2
                validity = true;
                return
            end

            % if testThisName is equal to defaultName return true
            if isequal(defaultName, testThisName)
                validity = true;
                return
            end
            
            % if testThisName is empty return true
            if obj.checkIfEmpty(testThisName)
                validity = true;
                return
            end

            % check validity
            if ischar(testThisName) || isstring(testThisName) || iscellstr(testThisName)
                if obj.isOctave
                    validity = size(testThisName, 1) == 1;
                else
                    validity = isequal(size(obj.string(testThisName)), [1, 1]);
                end
            end

            % convert to string if cellstr
            if iscellstr(testThisName) && validity
                testThisName = obj.string(testThisName);
            end

            % apply field name only if valid
            if validity
                returnName = testThisName;
            end
        end


        function empty = checkIfEmpty(obj, testThis)
            %{
            
            check if supplied text is empty
            
            Parameters
            ----------
            testThis : char or string or cellstr
                Name to test. If valid, returnName will be set to testThisName.
            
            Returns
            -------
            empty : logical
                - TRUE  if testThis is empty
                - FALSE if testThis is not empty

            %}
            
            if nargin == 1
                empty = true;
                return
            end
            
            % isempty("") returns FALSE in matlab
            if obj.isOctave
                empty = isempty(testThis);
            else
                empty = isempty(testThis) || obj.string(testThis)=="";
            end
        end



        function str = string(obj, vargin)
            %{
            Convert to string if matlab.
            For matlab/octave compatibility.
            %}
            if obj.isOctave
                str = vargin;
            else
                str = string(vargin);
            end
        end

    end % methods
end % class
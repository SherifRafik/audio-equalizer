classdef audio_equalizer_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        AudioEqualizerUIFigure          matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        EqualizerTab                    matlab.ui.container.Tab
        PlayerPanel                     matlab.ui.container.Panel
        BrowseButton                    matlab.ui.control.Button
        VolumeSliderLabel               matlab.ui.control.Label
        VolumeSlider                    matlab.ui.control.Slider
        PlayButton                      matlab.ui.control.Button
        PauseButton                     matlab.ui.control.Button
        StopButton                      matlab.ui.control.Button
        FileLabel                       matlab.ui.control.Label
        directoryLabel                  matlab.ui.control.Label
        Label_currentTime               matlab.ui.control.Label
        ofLabel                         matlab.ui.control.Label
        Label_totalTime                 matlab.ui.control.Label
        OutputsamplerateEditFieldLabel  matlab.ui.control.Label
        OutputsamplerateEditField       matlab.ui.control.NumericEditField
        SaveButton                      matlab.ui.control.Button
        FiltersPanel                    matlab.ui.container.Panel
        FilterTypeButtonGroup           matlab.ui.container.ButtonGroup
        IIRButton_2                     matlab.ui.control.RadioButton
        FIRButton                       matlab.ui.control.RadioButton
        FiltersGainPanel                matlab.ui.container.Panel
        Hz170HzSliderLabel              matlab.ui.control.Label
        channel1                        matlab.ui.control.Slider
        Hz310HzSliderLabel              matlab.ui.control.Label
        channel2                        matlab.ui.control.Slider
        Hz600HzLabel                    matlab.ui.control.Label
        channel3                        matlab.ui.control.Slider
        Hz1KHzLabel                     matlab.ui.control.Label
        channel4                        matlab.ui.control.Slider
        KHz3KHzSliderLabel              matlab.ui.control.Label
        channel5                        matlab.ui.control.Slider
        KHz6KHzSliderLabel              matlab.ui.control.Label
        channel6                        matlab.ui.control.Slider
        KHz12KHzSliderLabel             matlab.ui.control.Label
        channel7                        matlab.ui.control.Slider
        KHz14KHzSliderLabel             matlab.ui.control.Label
        channel8                        matlab.ui.control.Slider
        KHz16KHzSliderLabel             matlab.ui.control.Label
        channel9                        matlab.ui.control.Slider
        PresetsPanel                    matlab.ui.container.Panel
        PopButton                       matlab.ui.control.Button
        RockButton                      matlab.ui.control.Button
        TechnoButton                    matlab.ui.control.Button
        PartyButton                     matlab.ui.control.Button
        ClassicalButton                 matlab.ui.control.Button
        OriginalSignalTab               matlab.ui.container.Tab
        UIAxes_3                        matlab.ui.control.UIAxes
        UIAxes_4                        matlab.ui.control.UIAxes
        CompositeSignalTab_2            matlab.ui.container.Tab
        UIAxes                          matlab.ui.control.UIAxes
        UIAxes_2                        matlab.ui.control.UIAxes
        FilterAnalysisTab               matlab.ui.container.Tab
        FiltersPanel_2                  matlab.ui.container.Panel
        FIROrderLabel                   matlab.ui.control.Label
        directoryLabel_2                matlab.ui.control.Label
        IIROrderLabel                   matlab.ui.control.Label
        directoryLabel_3                matlab.ui.control.Label
        FilterAnalysisButton            matlab.ui.control.Button
    end

    
    methods (Access = public)
        
        function time = formatTime(~, seconds)
            minutes = floor(seconds / 60);
            seconds = seconds - minutes * 60;
            time = minutes + ":" + seconds;
        end
        
        function setTotalTime(app, size, Fs)
            global seconds;
            seconds = ceil(size / Fs);
            app.Label_totalTime.Text = formatTime(app, seconds);
            app.Label_currentTime.Text = "0:00";
        end
        
        function setCurrentTime(app)
            global playing;
            global seconds;
            global pausedAt;
            for i = 0 : seconds
                if(playing)
                    app.Label_currentTime.Text = formatTime(app, i);
                    pausedAt = i;
                    pause(1);
                end
            end
            if(pausedAt == seconds)
                app.Label_currentTime.Text = "0:00";
            end
        end
        
        function resumeCurrentTime(app)
            global playing;
            global seconds;
            global pausedAt;
            for i = pausedAt : seconds
                if(playing)
                    app.Label_currentTime.Text = formatTime(app, i);
                    pause(1);
                    temp = i;
                end
            end
            pausedAt = temp;
            if(pausedAt == seconds)
                app.Label_currentTime.Text = "0:00";
            end
        end
    
        function setFilters(~,Fs,firOrder,iirOrder)
            global iirFilter;
            global numerator;
            global denominator;
            global frequencies;
            if (iirFilter == true)
                [numerator{1}, denominator{1}] = butter(iirOrder,frequencies(2)/(Fs/2));
                for i = 2 : 9
                     [numerator{i},denominator{i}] = butter(iirOrder,[frequencies(i) frequencies(i+1)]/(Fs/2));
                end
            else
                numerator{1} = fir1(firOrder , frequencies(2)/(Fs/2));
                for i = 2 : 9
                    numerator{i} = fir1(firOrder, [frequencies(i) frequencies(i+1)]/(Fs/2));
                end
            end
        end
    
        function filterSound(~,y)
            global filteredSound;
            global iirFilter;
            filteredSound = cell(9,1);
            global numerator;
            global denominator;
            if (iirFilter == true)
                for i = 1 : 9
                    filteredSound{i} = filter(numerator{i} , denominator{i}, y);
                end
            else
               for i = 1 : 9
                    filteredSound{i} = filter(numerator{i} , 1, y);
               end
            end
        end   
    
        function getSliders(app)
            global slidersValues;
            slidersValues(1) = app.channel1.Value;
            slidersValues(2) = app.channel2.Value;
            slidersValues(3) = app.channel3.Value;
            slidersValues(4) = app.channel4.Value;
            slidersValues(5) = app.channel5.Value;
            slidersValues(6) = app.channel6.Value;
            slidersValues(7) = app.channel7.Value;
            slidersValues(8) = app.channel8.Value;
            slidersValues(9) = app.channel9.Value;
        end
    
        function compositeSignal =  getCompositeSignal(~)
            global slidersValues;
            global filteredSound;
            compositeSignal = 10^(slidersValues(1)/20) * filteredSound{1};
            for i = 2 : 9
                compositeSignal = compositeSignal + (10^(slidersValues(i)/20) * filteredSound{i});
            end
        end
    
        function time = calculateTime(~,signal,Fs)
            dt = 1/Fs;
            time = 0:dt:(length(signal)*dt)-dt;
        end
    
        function frequency = calculateFrequency(~,signal,Fs)
            n = length(signal) - 1;
            frequency = 0:Fs/n:Fs;
        end
        
        function filterResponse(~)
            global numerator;
            global denominator;
            global iirFilter;
            fig = figure(11);
            pos = get(fig, 'position');
            set(fig,'position',[pos(1:2)/3 pos(3:4)*1.5]);
            for i = 1 : 9  
                subplot(3,3,i);
                if iirFilter == true
                    impz(numerator{i},denominator{i});
                else
                    impz(numerator{i},1);
                end
            end
            fig = figure(12);
            pos = get(fig, 'position');
            set(fig,'position',[pos(1:2)/3 pos(3:4)*1.5]);
            for i = 1 : 9  
                subplot(3,3,i);
                if iirFilter == true
                    stepz(numerator{i},denominator{i});
                else
                    stepz(numerator{i},1);
                end
            end
        end
    
        function gainPhaseFilter(~)
            global numerator;
            global denominator;
            global iirFilter;
            for i = 1 : 9  
            fig = figure(i);
            pos = get(fig, 'position');
            set(fig,'position',[pos(1:2)/3 pos(3:4)*1.5]);
                if iirFilter == true
                    freqz(numerator{i},denominator{i});
                else
                    freqz(numerator{i},1);
                end
            end
        end
    
        function zerosPolesFilter(~)
            global numerator;
            global denominator;
            global iirFilter;
            fig = figure(10);
            pos = get(fig, 'position');
            set(fig,'position',[pos(1:2)/3 pos(3:4)*1.5]);
            for i = 1 : 9  
                subplot(3,3,i);
                if iirFilter == true
                    transferFunction = tf(numerator{i},denominator{i});
                    pzmap(transferFunction);
                else
                    transferFunction = tf(numerator{i},1);
                    pzmap(transferFunction);
                end
            end
        end
    
    
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            global iirFilter; %boolean true if iirfilter is used
            global firFilter; %boolean true if firfilter is used
            global frequencies; %frequencies array
            global numerator; 
            global denominator;
            global slidersValues;
            global firOrder;
            global iirOrder;
            frequencies =[0,170,310,600,1000,3000,6000,12000,14000,16000];
            firFilter = false;
            iirFilter = true;
            numerator = cell(9,1);
            denominator = cell(9,1);
            slidersValues = [];
            firOrder = 30;
            iirOrder = 2;
        end

        % Button pushed function: BrowseButton
        function BrowseButtonPushed(app, event)
            [file,path] = uigetfile({'*.wav'},'Selec a wav file');
            global file_path;
            global playing;
            global paused;
            if ~isequal(file,0)
                file_path = fullfile(path,file);
                app.directoryLabel.Text = file;
                playing = false;
                paused = false;
            end
        end

        % Button pushed function: PopButton
        function PopButtonPushed(app, event)
            app.channel1.Value = -1.5;
            app.channel2.Value =  3.9;
            app.channel3.Value =  5.4;
            app.channel4.Value =  4.5;
            app.channel5.Value =  0.9;
            app.channel6.Value = -1.5;
            app.channel7.Value = -1.8;
            app.channel8.Value = -2.1;
            app.channel9.Value = -2.1;
        end

        % Button pushed function: RockButton
        function RockButtonPushed(app, event)
            app.channel1.Value =  4.5;
            app.channel2.Value = -3.6;
            app.channel3.Value = -6.6;
            app.channel4.Value = -2.7;
            app.channel5.Value =  2.1;
            app.channel6.Value =  6.0;
            app.channel7.Value =  7.5;
            app.channel8.Value =  7.8;
            app.channel9.Value =  7.8;
        end

        % Button pushed function: TechnoButton
        function TechnoButtonPushed(app, event)
            app.channel1.Value =  4.8;
            app.channel2.Value =  4.2;
            app.channel3.Value =  1.5;
            app.channel4.Value = -2.4;
            app.channel5.Value = -3.3;
            app.channel6.Value = -1.5;
            app.channel7.Value =  1.5;
            app.channel8.Value =  5.1;
            app.channel9.Value =  5.7;
        end

        % Button pushed function: PartyButton
        function PartyButtonPushed(app, event)
            app.channel1.Value =  5.4;
            app.channel2.Value =  0.0;
            app.channel3.Value =  0.0;
            app.channel4.Value =  0.0;
            app.channel5.Value =  0.0;
            app.channel6.Value =  0.0;
            app.channel7.Value =  0.0;
            app.channel8.Value =  0.0;
            app.channel9.Value =  0.0;
        end

        % Button pushed function: ClassicalButton
        function ClassicalButtonPushed(app, event)
            app.channel1.Value =  0.0;
            app.channel2.Value =  0.0;
            app.channel3.Value =  0.0;
            app.channel4.Value =  0.0;
            app.channel5.Value =  0.0;
            app.channel6.Value =  0.0;
            app.channel7.Value = -0.3;
            app.channel8.Value = -5.7;
            app.channel9.Value = -6.0;
        end

        % Button pushed function: PlayButton
        function PlayButtonPushed(app, event)
            global player;
            global paused;
            global playing;
            global file_path;
            global compositeSignal;
            global firOrder;
            global iirOrder;
            if paused
                playing = true;
                resume(player);
                resumeCurrentTime(app);
            end
            if ~playing
                [y, Fs] = audioread(file_path);
                userDefinedFs = app.OutputsamplerateEditField.Value;
                y = resample(y,userDefinedFs,Fs);
                size = length(y);
                setTotalTime(app, size, userDefinedFs);
                setFilters(app,userDefinedFs,firOrder,iirOrder);
                filterSound(app,y);
                getSliders(app);
                compositeSignal = getCompositeSignal(app);
                compositeSignal = app.VolumeSlider.Value * compositeSignal;
                player = audioplayer(compositeSignal, userDefinedFs);
                time = calculateTime(app,compositeSignal,userDefinedFs);
                plot(app.UIAxes,time,compositeSignal);
                frequency = calculateFrequency(app,compositeSignal,userDefinedFs);
                plot(app.UIAxes_2,frequency,abs(fftshift(fft(compositeSignal))));
                time = calculateTime(app,y,userDefinedFs);
                plot(app.UIAxes_3,time,y);
                frequency = calculateFrequency(app,y,userDefinedFs);
                plot(app.UIAxes_4,frequency,abs(fftshift(fft(y))));
                playing = true;
                play(player);
                setCurrentTime(app);
            end
        end

        % Button pushed function: PauseButton
        function PauseButtonPushed(app, event)
            global player;
            global paused;
            global playing;
            if playing
                playing = false;
                pause(player);
                paused = true;
            end
        end

        % Button pushed function: StopButton
        function StopButtonPushed(app, event)
            global player;
            global playing;
            global paused;
            global pausedAt;
            playing = false;
            paused = false;
            stop(player);
            app.Label_currentTime.Text = "0:00";
            pausedAt = 0;
        end

        % Selection changed function: FilterTypeButtonGroup
        function FilterTypeButtonGroupSelectionChanged(app, event)
            selectedButton = app.FilterTypeButtonGroup.SelectedObject;
            global iirFilter;
            global firFilter;
            if selectedButton.Text == "IIR"
                iirFilter = true;
                firFilter = false;
            else
                firFilter = true;
                iirFilter = false;
            end
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            global compositeSignal;
            userDefinedFs = app.OutputsamplerateEditField.Value;
            audiowrite('output.wav',compositeSignal,userDefinedFs);
        end

        % Button pushed function: FilterAnalysisButton
        function FilterAnalysisButtonPushed(app, event)
            gainPhaseFilter(app);
            zerosPolesFilter(app);
            filterResponse(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create AudioEqualizerUIFigure and hide until all components are created
            app.AudioEqualizerUIFigure = uifigure('Visible', 'off');
            app.AudioEqualizerUIFigure.Position = [650 400 729 549];
            app.AudioEqualizerUIFigure.Name = 'Audio Equalizer';
            app.AudioEqualizerUIFigure.Resize = 'off';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.AudioEqualizerUIFigure);
            app.TabGroup.Position = [1 1 729 549];

            % Create EqualizerTab
            app.EqualizerTab = uitab(app.TabGroup);
            app.EqualizerTab.Title = 'Equalizer';

            % Create PlayerPanel
            app.PlayerPanel = uipanel(app.EqualizerTab);
            app.PlayerPanel.Title = 'Player';
            app.PlayerPanel.Position = [28 349 675 160];

            % Create BrowseButton
            app.BrowseButton = uibutton(app.PlayerPanel, 'push');
            app.BrowseButton.ButtonPushedFcn = createCallbackFcn(app, @BrowseButtonPushed, true);
            app.BrowseButton.Icon = 'icons8-search-26.png';
            app.BrowseButton.Position = [538 108 100 22];
            app.BrowseButton.Text = 'Browse';

            % Create VolumeSliderLabel
            app.VolumeSliderLabel = uilabel(app.PlayerPanel);
            app.VolumeSliderLabel.HorizontalAlignment = 'right';
            app.VolumeSliderLabel.Position = [356 41 45 22];
            app.VolumeSliderLabel.Text = 'Volume';

            % Create VolumeSlider
            app.VolumeSlider = uislider(app.PlayerPanel);
            app.VolumeSlider.Position = [422 50 214 3];
            app.VolumeSlider.Value = 50;

            % Create PlayButton
            app.PlayButton = uibutton(app.PlayerPanel, 'push');
            app.PlayButton.ButtonPushedFcn = createCallbackFcn(app, @PlayButtonPushed, true);
            app.PlayButton.Icon = 'icons8-play-24.png';
            app.PlayButton.Position = [13 29 63 22];
            app.PlayButton.Text = 'Play';

            % Create PauseButton
            app.PauseButton = uibutton(app.PlayerPanel, 'push');
            app.PauseButton.ButtonPushedFcn = createCallbackFcn(app, @PauseButtonPushed, true);
            app.PauseButton.Icon = 'icons8-pause-24.png';
            app.PauseButton.Position = [101 29 63 22];
            app.PauseButton.Text = 'Pause';

            % Create StopButton
            app.StopButton = uibutton(app.PlayerPanel, 'push');
            app.StopButton.ButtonPushedFcn = createCallbackFcn(app, @StopButtonPushed, true);
            app.StopButton.Icon = 'icons8-stop-26.png';
            app.StopButton.Position = [187 29 63 22];
            app.StopButton.Text = 'Stop';

            % Create FileLabel
            app.FileLabel = uilabel(app.PlayerPanel);
            app.FileLabel.Position = [13 108 27 22];
            app.FileLabel.Text = 'File:';

            % Create directoryLabel
            app.directoryLabel = uilabel(app.PlayerPanel);
            app.directoryLabel.HorizontalAlignment = 'center';
            app.directoryLabel.Position = [47 108 476 22];
            app.directoryLabel.Text = 'Load file first';

            % Create Label_currentTime
            app.Label_currentTime = uilabel(app.PlayerPanel);
            app.Label_currentTime.Position = [125 69 28 22];
            app.Label_currentTime.Text = '--:--';

            % Create ofLabel
            app.ofLabel = uilabel(app.PlayerPanel);
            app.ofLabel.Position = [175 69 19 22];
            app.ofLabel.Text = 'of';

            % Create Label_totalTime
            app.Label_totalTime = uilabel(app.PlayerPanel);
            app.Label_totalTime.Position = [208 69 28 22];
            app.Label_totalTime.Text = '--:--';

            % Create OutputsamplerateEditFieldLabel
            app.OutputsamplerateEditFieldLabel = uilabel(app.PlayerPanel);
            app.OutputsamplerateEditFieldLabel.HorizontalAlignment = 'right';
            app.OutputsamplerateEditFieldLabel.Position = [415 69 108 22];
            app.OutputsamplerateEditFieldLabel.Text = 'Output sample rate';

            % Create OutputsamplerateEditField
            app.OutputsamplerateEditField = uieditfield(app.PlayerPanel, 'numeric');
            app.OutputsamplerateEditField.Limits = [32000 Inf];
            app.OutputsamplerateEditField.ValueDisplayFormat = '%.0f';
            app.OutputsamplerateEditField.HorizontalAlignment = 'left';
            app.OutputsamplerateEditField.Position = [538 69 100 22];
            app.OutputsamplerateEditField.Value = 44100;

            % Create SaveButton
            app.SaveButton = uibutton(app.PlayerPanel, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.Position = [272 29 63 22];
            app.SaveButton.Text = 'Save';

            % Create FiltersPanel
            app.FiltersPanel = uipanel(app.EqualizerTab);
            app.FiltersPanel.Title = 'Filters';
            app.FiltersPanel.Position = [29 17 673 320];

            % Create FilterTypeButtonGroup
            app.FilterTypeButtonGroup = uibuttongroup(app.FiltersPanel);
            app.FilterTypeButtonGroup.SelectionChangedFcn = createCallbackFcn(app, @FilterTypeButtonGroupSelectionChanged, true);
            app.FilterTypeButtonGroup.Title = 'Filter Type';
            app.FilterTypeButtonGroup.Position = [12 240 137 52];

            % Create IIRButton_2
            app.IIRButton_2 = uiradiobutton(app.FilterTypeButtonGroup);
            app.IIRButton_2.Text = 'IIR';
            app.IIRButton_2.Position = [11 6 40 22];
            app.IIRButton_2.Value = true;

            % Create FIRButton
            app.FIRButton = uiradiobutton(app.FilterTypeButtonGroup);
            app.FIRButton.Text = 'FIR';
            app.FIRButton.Position = [69 6 41 22];

            % Create FiltersGainPanel
            app.FiltersGainPanel = uipanel(app.FiltersPanel);
            app.FiltersGainPanel.Title = 'Filters Gain';
            app.FiltersGainPanel.Position = [12 10 649 221];

            % Create Hz170HzSliderLabel
            app.Hz170HzSliderLabel = uilabel(app.FiltersGainPanel);
            app.Hz170HzSliderLabel.HorizontalAlignment = 'center';
            app.Hz170HzSliderLabel.Position = [16 1 43 28];
            app.Hz170HzSliderLabel.Text = {'0 Hz'; '170 Hz'};

            % Create channel1
            app.channel1 = uislider(app.FiltersGainPanel);
            app.channel1.Limits = [-12 12];
            app.channel1.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel1.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel1.Orientation = 'vertical';
            app.channel1.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel1.Position = [27 37 3 150];

            % Create Hz310HzSliderLabel
            app.Hz310HzSliderLabel = uilabel(app.FiltersGainPanel);
            app.Hz310HzSliderLabel.HorizontalAlignment = 'center';
            app.Hz310HzSliderLabel.Position = [87 1 43 28];
            app.Hz310HzSliderLabel.Text = {'170 Hz'; '310 Hz'};

            % Create channel2
            app.channel2 = uislider(app.FiltersGainPanel);
            app.channel2.Limits = [-12 12];
            app.channel2.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel2.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel2.Orientation = 'vertical';
            app.channel2.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel2.Position = [98 37 3 150];

            % Create Hz600HzLabel
            app.Hz600HzLabel = uilabel(app.FiltersGainPanel);
            app.Hz600HzLabel.HorizontalAlignment = 'center';
            app.Hz600HzLabel.Position = [156 3 44 28];
            app.Hz600HzLabel.Text = {'310 Hz'; '600 Hz'};

            % Create channel3
            app.channel3 = uislider(app.FiltersGainPanel);
            app.channel3.Limits = [-12 12];
            app.channel3.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel3.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel3.Orientation = 'vertical';
            app.channel3.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel3.Position = [166 39 3 150];

            % Create Hz1KHzLabel
            app.Hz1KHzLabel = uilabel(app.FiltersGainPanel);
            app.Hz1KHzLabel.HorizontalAlignment = 'center';
            app.Hz1KHzLabel.Position = [223 3 44 28];
            app.Hz1KHzLabel.Text = {'600 Hz'; '1 KHz'};

            % Create channel4
            app.channel4 = uislider(app.FiltersGainPanel);
            app.channel4.Limits = [-12 12];
            app.channel4.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel4.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel4.Orientation = 'vertical';
            app.channel4.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel4.Position = [234 39 3 150];

            % Create KHz3KHzSliderLabel
            app.KHz3KHzSliderLabel = uilabel(app.FiltersGainPanel);
            app.KHz3KHzSliderLabel.HorizontalAlignment = 'center';
            app.KHz3KHzSliderLabel.Position = [297 1 38 28];
            app.KHz3KHzSliderLabel.Text = {'1 KHz'; '3 KHz'};

            % Create channel5
            app.channel5 = uislider(app.FiltersGainPanel);
            app.channel5.Limits = [-12 12];
            app.channel5.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel5.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel5.Orientation = 'vertical';
            app.channel5.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel5.Position = [305 37 3 150];

            % Create KHz6KHzSliderLabel
            app.KHz6KHzSliderLabel = uilabel(app.FiltersGainPanel);
            app.KHz6KHzSliderLabel.HorizontalAlignment = 'center';
            app.KHz6KHzSliderLabel.Position = [362 1 38 28];
            app.KHz6KHzSliderLabel.Text = {'3 KHz'; '6 KHz'};

            % Create channel6
            app.channel6 = uislider(app.FiltersGainPanel);
            app.channel6.Limits = [-12 12];
            app.channel6.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel6.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel6.Orientation = 'vertical';
            app.channel6.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel6.Position = [370 37 3 150];

            % Create KHz12KHzSliderLabel
            app.KHz12KHzSliderLabel = uilabel(app.FiltersGainPanel);
            app.KHz12KHzSliderLabel.HorizontalAlignment = 'center';
            app.KHz12KHzSliderLabel.Position = [427 1 45 28];
            app.KHz12KHzSliderLabel.Text = {'6 KHz'; '12 KHz'};

            % Create channel7
            app.channel7 = uislider(app.FiltersGainPanel);
            app.channel7.Limits = [-12 12];
            app.channel7.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel7.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel7.Orientation = 'vertical';
            app.channel7.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel7.Position = [439 37 3 150];

            % Create KHz14KHzSliderLabel
            app.KHz14KHzSliderLabel = uilabel(app.FiltersGainPanel);
            app.KHz14KHzSliderLabel.HorizontalAlignment = 'center';
            app.KHz14KHzSliderLabel.Position = [499 3 45 28];
            app.KHz14KHzSliderLabel.Text = {'12 KHz'; '14 KHz'};

            % Create channel8
            app.channel8 = uislider(app.FiltersGainPanel);
            app.channel8.Limits = [-12 12];
            app.channel8.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel8.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel8.Orientation = 'vertical';
            app.channel8.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel8.Position = [511 39 3 150];

            % Create KHz16KHzSliderLabel
            app.KHz16KHzSliderLabel = uilabel(app.FiltersGainPanel);
            app.KHz16KHzSliderLabel.HorizontalAlignment = 'center';
            app.KHz16KHzSliderLabel.Position = [571 3 45 28];
            app.KHz16KHzSliderLabel.Text = {'14 KHz'; '16 KHz'};

            % Create channel9
            app.channel9 = uislider(app.FiltersGainPanel);
            app.channel9.Limits = [-12 12];
            app.channel9.MajorTicks = [-12 -9 -6 -3 0 3 6 9 12];
            app.channel9.MajorTickLabels = {'-12 dB', '', '-6 dB', '', '0 dB', '', '6 dB', '', '12 dB'};
            app.channel9.Orientation = 'vertical';
            app.channel9.MinorTicks = [-12 -11 -10 -9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 8 9 10 11 12];
            app.channel9.Position = [583 39 3 150];

            % Create PresetsPanel
            app.PresetsPanel = uipanel(app.FiltersPanel);
            app.PresetsPanel.Title = 'Presets';
            app.PresetsPanel.Position = [158 240 503 52];

            % Create PopButton
            app.PopButton = uibutton(app.PresetsPanel, 'push');
            app.PopButton.ButtonPushedFcn = createCallbackFcn(app, @PopButtonPushed, true);
            app.PopButton.Position = [8 6 70 22];
            app.PopButton.Text = 'Pop';

            % Create RockButton
            app.RockButton = uibutton(app.PresetsPanel, 'push');
            app.RockButton.ButtonPushedFcn = createCallbackFcn(app, @RockButtonPushed, true);
            app.RockButton.Position = [112 6 70 22];
            app.RockButton.Text = 'Rock';

            % Create TechnoButton
            app.TechnoButton = uibutton(app.PresetsPanel, 'push');
            app.TechnoButton.ButtonPushedFcn = createCallbackFcn(app, @TechnoButtonPushed, true);
            app.TechnoButton.Position = [216 6 70 22];
            app.TechnoButton.Text = 'Techno';

            % Create PartyButton
            app.PartyButton = uibutton(app.PresetsPanel, 'push');
            app.PartyButton.ButtonPushedFcn = createCallbackFcn(app, @PartyButtonPushed, true);
            app.PartyButton.Position = [320 6 70 22];
            app.PartyButton.Text = 'Party';

            % Create ClassicalButton
            app.ClassicalButton = uibutton(app.PresetsPanel, 'push');
            app.ClassicalButton.ButtonPushedFcn = createCallbackFcn(app, @ClassicalButtonPushed, true);
            app.ClassicalButton.Position = [424 6 70 22];
            app.ClassicalButton.Text = 'Classical';

            % Create OriginalSignalTab
            app.OriginalSignalTab = uitab(app.TabGroup);
            app.OriginalSignalTab.Title = 'Original Signal';

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.OriginalSignalTab);
            title(app.UIAxes_3, 'Original Signal in Time domain')
            xlabel(app.UIAxes_3, 'Time')
            ylabel(app.UIAxes_3, 'Magnitude')
            app.UIAxes_3.PlotBoxAspectRatio = [3.6195652173913 1 1];
            app.UIAxes_3.XGrid = 'on';
            app.UIAxes_3.XMinorGrid = 'on';
            app.UIAxes_3.YGrid = 'on';
            app.UIAxes_3.YMinorGrid = 'on';
            app.UIAxes_3.Position = [2 260 715 240];

            % Create UIAxes_4
            app.UIAxes_4 = uiaxes(app.OriginalSignalTab);
            title(app.UIAxes_4, 'Original Signal in Frequency domain')
            xlabel(app.UIAxes_4, 'Frequency')
            ylabel(app.UIAxes_4, 'Magnitude')
            app.UIAxes_4.PlotBoxAspectRatio = [3.6195652173913 1 1];
            app.UIAxes_4.XGrid = 'on';
            app.UIAxes_4.XMinorGrid = 'on';
            app.UIAxes_4.YGrid = 'on';
            app.UIAxes_4.YMinorGrid = 'on';
            app.UIAxes_4.Position = [1 10 715 240];

            % Create CompositeSignalTab_2
            app.CompositeSignalTab_2 = uitab(app.TabGroup);
            app.CompositeSignalTab_2.Title = 'Composite Signal';

            % Create UIAxes
            app.UIAxes = uiaxes(app.CompositeSignalTab_2);
            title(app.UIAxes, 'Composite Signal in Time domain')
            xlabel(app.UIAxes, 'Time')
            ylabel(app.UIAxes, 'Magnitude')
            app.UIAxes.PlotBoxAspectRatio = [3.6195652173913 1 1];
            app.UIAxes.XMinorGrid = 'on';
            app.UIAxes.YMinorGrid = 'on';
            app.UIAxes.Position = [2 260 715 240];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.CompositeSignalTab_2);
            title(app.UIAxes_2, 'Composite Signal in Frequency domain')
            xlabel(app.UIAxes_2, 'Frequency')
            ylabel(app.UIAxes_2, 'Magnitude')
            app.UIAxes_2.PlotBoxAspectRatio = [3.6195652173913 1 1];
            app.UIAxes_2.XGrid = 'on';
            app.UIAxes_2.XMinorGrid = 'on';
            app.UIAxes_2.YGrid = 'on';
            app.UIAxes_2.YMinorGrid = 'on';
            app.UIAxes_2.Position = [1 10 715 240];

            % Create FilterAnalysisTab
            app.FilterAnalysisTab = uitab(app.TabGroup);
            app.FilterAnalysisTab.Title = 'Filter Analysis';

            % Create FiltersPanel_2
            app.FiltersPanel_2 = uipanel(app.FilterAnalysisTab);
            app.FiltersPanel_2.Title = 'Filters';
            app.FiltersPanel_2.Position = [17 384 489 125];

            % Create FIROrderLabel
            app.FIROrderLabel = uilabel(app.FiltersPanel_2);
            app.FIROrderLabel.Position = [21 65 59 22];
            app.FIROrderLabel.Text = 'FIR Order';

            % Create directoryLabel_2
            app.directoryLabel_2 = uilabel(app.FiltersPanel_2);
            app.directoryLabel_2.HorizontalAlignment = 'center';
            app.directoryLabel_2.Position = [79 65 230 22];
            app.directoryLabel_2.Text = '30';

            % Create IIROrderLabel
            app.IIROrderLabel = uilabel(app.FiltersPanel_2);
            app.IIROrderLabel.Position = [21 28 55 22];
            app.IIROrderLabel.Text = 'IIR Order';

            % Create directoryLabel_3
            app.directoryLabel_3 = uilabel(app.FiltersPanel_2);
            app.directoryLabel_3.HorizontalAlignment = 'center';
            app.directoryLabel_3.Position = [79 28 230 22];
            app.directoryLabel_3.Text = '2';

            % Create FilterAnalysisButton
            app.FilterAnalysisButton = uibutton(app.FiltersPanel_2, 'push');
            app.FilterAnalysisButton.ButtonPushedFcn = createCallbackFcn(app, @FilterAnalysisButtonPushed, true);
            app.FilterAnalysisButton.Position = [356 43 100 22];
            app.FilterAnalysisButton.Text = 'Filter Analysis';

            % Show the figure after all components are created
            app.AudioEqualizerUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = audio_equalizer_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.AudioEqualizerUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.AudioEqualizerUIFigure)
        end
    end
end
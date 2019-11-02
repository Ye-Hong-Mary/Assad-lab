%% CLASS_photometry_roadmapv1_4.m: Create photometry object for roadmapv1_4 *** FOR MARY!!!!!!!!!!!!!!!
% 
%   Created: 8-10-18		ahamilos  
% 	LastMod: 10-16-19		ahamilos  
% 
% Update log:
% 	VERSION 3.x
% 	9	- 8/10/19:	Wow, anniversary edition!!!!!
% 					Added ability to create primarily optogenetics objects	(see Optogenetics v3.9x Development presentation for Documentation)
%					Modeled off of AUTORUN_optogenetics_postprocessing_roadmapv1_4, except not dependent on running roadmapv1_4 to pre-process 
% 
% 		- a ton of AutoGLM adjustments...
% 		- 3/17/19:	Making more adjustments for the AutoGLMdraft.m development
% 	8 	- 3/12/19:	Trimming down nestedGLM 2.6 -- commenting out some plots, preparing for use with AUTOglm v3x8
% 
% 	7	- 2/25/19:	Removed redundant obj.GLM.pos.fLick (capitalized) - because was getting confused with proper .flick field
% 						Also detected inappropriate all_flick_wrtc_ms conversion to 1/samples in obj.getBinnedTimeseries -- will have affected non-photometry data
% 	6	- 2/20/19:	Added method for correcting sampling rate that should automatically check if rate is correct in files.
% 	5	- 2/12/19:	Had been keeping (1-n)/n in the binned timeseries running ave - changed to nC and nL dot div as approp 
% 						Also fixed this for the v3x method - now ready to use 
% 	4	- 2/11/19:	v3x method working for VTAred data - tested with combo of B5! Very good
% 						Begin to add stim/nostim method for binning
% 	3	- 2/8//19:	Trying in earnest to get v3.x to work for combining datasets
% 						Adding a Z score method: works (obj.Zscorevector)
% 						Method will Z score datasets before combining. 
% 	2	- 2/6/19:	Corrected the normalized multibaseline method to kill noise and the photNstim method to chop stim up times properly.
% 	1	- 1/25/19:	Version allowing creation of objects from photometry data using either gfit files and timestamps from folder or raw data... Needs lots of debug!
% 
% 	VERSION 2.x
% 	17  - 2/1/19:	Adding chop gfit method for stim and photometry data...
%   16  - 1/22/19:  Added a lot of stuff - more binning methods, noted bug
%                   in obj.GLM.pos.lampOff and updated the test obj
% 	15	- 1/10/19:	Adding paired-trial analysis methods for binning CTAs, LTAs, etc... for single session
% 	14	- 1/9/19:	Added tools for testing gFit by different methodlogies, as well as binning and processing any arbitrary timeseries
% 	13	- 12/19/18:	Implementing to-do tasklist from Chicha Meeting on 12/18/18
% 	12	- 12/18/18:	Added nTime method to baselineGLM -- but not yet using matlab's fitglm. Also did a lot of debugging to clean this function up
% 	11	- 12/12/18:	Lots of updates -- now have Xvalidation, LagRegression, BaselineGLM, and other optimizations.
% 	10	- 11/19/18: Version working in a dope fashion and recapitulating CTA pretty well.
% 					NOTED CRITICAL ISSUE -- ramp convolutions overlap into adjoining trials and shouldn't!!! Must fix with a zero mask after convolving
% 					NEED TO CHECK that trials are actually getting put into place in correct alignment - looks ok, but need to verify...
% 						Updating the convolution method to have a zeros mask...
% 	9	- 11/14/18:	New methods for GLM, including EMG, EMGdelta, and analysis of EMG spike frequency during timing interval
% 	8	- 11/6/18:	CRITICAL BUG FIXED - data.iv.time_parameters.lick.samples_wrtCueArray was off by ~100ms - fixed now in obj processing!
% 							Unclear why this happened. The seconds timestamp in data.lick_data_struct. is the most reliable. May have something to do with individual
% 							days and how they were processed or the shifting procedure when combining days. Unclear... So I'll just fix it here.
% 	7	- 11/1/18:	Discovered that for 'trials' mode CLTA_BinCenter not calc'd correctly. I think is fixed now, take caution with old objs!
% 	6	- 10/29/18:	Modifying a-trimming to allow 'trial2lick' input, which will only consider times between trial start and the lick and concat these
% 	5   - 10/28/18:	Got ridge analytical and GD working
% 	4	- 10/24/18: Implementing ramp function for making x-rep of timing interval
% 	3	- 10/23/18:	First working version of nested GLM with analytical regression (ridge not done yet)
% 	2	- 10/15/18:	Making compatible with non-combined datasets (for GLM purposes)
% 	1	- 10/11/18:	Created nested GLM functions and began implementing cases to hang onto gfits, event sequences, etc for nested GLM
% 
% 	VERSION 1.x
% 		- 10/9/18:	Added vertical threshold method
% 		- 10/8/18:	Continued on horizontal threshold. Added CTA2l method
% 					Cleaned up CTA2l plots
% 					Created inset for .Plot method so you can call from other methods
% 		- 10/6/18:	Added method for horizontal threshold
% 		- 9/13/18:	Writing plotting methods for stim/unstim...
% 		- 9/12/18:	Wrote binning method for stim/unstim. Need to test
% 					Need to write a plotting method specific for photNstim that will make 2 plots, one for stim, one for unstim
% 		- 9/10/18:	Worked to incorporate photometry/stim condition. Look to see if is a field of 
% 						init_variables.photNstim and if so == 1, then make stim functions available
% 		- 8/16/18:	Validated that both binning methods working correctly.
% 					Wrote plotting fxs for bins
% 		- 8/13/18:	Attempting to fix the siITI licks lost from the combined data structure...
% 						Corrected and validated!
% 		- 8/12/18:	Implemented binning procedure. Tested for times and is ok for 1 bin.
% 
%  combined_data_struct.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial = LT si iti data
% 
% MODES: 'Times' or 'Trials'
% 
% 
% GENERAL TO-DO:
% 		-- for photNstim: update binning function to make a stim datase and a no-stim dataset. 
% 		-- Then write cases to plot these separately for all subsequent functions
% 
% 
% 
% DEBUG SCHEDULE:
% 		-- not detecting all the siITI licks in the getPlot function - somehow only 328: 
% 			- looks like it was an error with the initial processing, so we can reprocess here to fix this
% 			- we will check if the length of the samples wrt last lick differs from the number of siITI licks and then redo this
% 			- Note that redoing this method with the combined dataset returns FEWER siITI licks than did original processing. 
% 				og: 3929, new processing: 3547 (so roughly 400 extra, and they are intermixed in the dataset (e.g., o.g. si licks 2 and 3 missing from redone))
% 				However, original processing is suspect because the CLASS method uses the same strategy. I'm not sure why we lose licks
% 				but it could be due to:
% 					X gITI exclusions (ruled out)
% 					AH! It's due to excluded trials! Apparently in roadmap we put in lick_times_by_trial not lick_ex_times_by_trial, 
% 					so we were getting the un-excluded form. I suppose it works out the same way since excluded trials have no data when plotting. Also makes sense if wanted to use without exclusions
% 					THUS for purposes of combined data, we will stick with the lick_ex_times_by_trial for a more approp count of siITI licks...
% 					THUS, we will redo siITI for all datasets no matter what!
% 					
% 		-- log not accepting input after generation of object from cmd line...
% 
% 		-- CTA up to lick isn't including reaction trials. We probably want to.....
% 
% 		-- Need to be able to combine objects across mice. probably time bins is the only way to do reasonably. Maybe a large number of bins
% 
% 
% 	STATS SCHEDULE:
% 
% 		-- try ANOVA next
% --------------------------------------------------------------------------------------

classdef CLASS_photometry_roadmapv1_4 < handle
	properties 
		Plot 			% Keeps track of plotting parameters, including lick times/positions
		iv 				% Holds on to init variables... or some of them
		Mode
		BinParams
		BinnedData
		SaveMode
		Log
		Stat
		Stim
		ChR2
		gFitLP
		GLM
		ts
		CtrlCh
		video
	end

	%-------------------------------------------------------
	%		Methods: Initialization
	%-------------------------------------------------------
	methods
		function obj = CLASS_photometry_roadmapv1_4(data, Mode, nbins, gfit, gtimes, xRaw, xTimes, stimMode) % choose large nbins to retain resolution
			% 
			% 	Version 3.x: Now we allow user to select data from a folder of files and to combine using ts methods...
			% 				The idea is that we will be processing multiple files at once. Of course, we could do single files this way, too, instead of using Roadmap in the future
			% 		data: a string, '3.x'
			% 			Some variables have different meanings now:
			% 				Mode tags work with the new ts method -- we will use the ts method to bin the current file, 
			% 					then we will append it to the main file's binning on each iteration
			% 				nbins = depends on Mode
			% 				gfit = the gfit style to use. {'RawF'}, {'Box', window}, {'MultiBaseline', nTrials}
			% 						Note that if gfit {'Box', window} is specified, we will look for a gfit file in the folder and if it's not there, we will calc it from scratch...
			% 				gtimes = the timepad to use for both CTA and LTA...
			% 
			% 		data: '3.x' for combining data...
			% 
			% 		data: 'stimNphot' to make a stim and phot obj with gfit on the chopped data
			% 		stimMode = 'off' - no stimulation data (or ignored distinction)
			% 					'noStim' - only do nonstimulated trials
			% 					'stim' - use only stimulated trials
			% 				
			% 
			% How it works: When we initialize the object, it converts the huge dataset 
			% 				into a finely-binned CTA, LTA, and siITI dataset. We can always get fewer bins
			% 				by averaging the bins later on.
			% 		  Mode:	This will decide whether we want to use even-timerange blocks or even #s of trials 
			% 				in each block
			% 				"Times" or "Trials" ---- for times, put the # of bins you want; 
			% 									---- for trials, put the number of trials per bin
			% 				"Outcome"			---- breaks into early and rewarded responses (also reaction and ITI)
			% -------------------------------------------------------------
			% 
			% 	Defaults: will save after creation of object immediately to the current directory
			% 
			
			if isstr(data) && (strcmpi(data, '3.x') || strcmpi(data, 'v3x'))
				warning('off','MATLAB:Figure:FigureSavedToMATFile')
				warning(sprintf('VERSION NOTES: \n\n Only use v3x for forced 0ms rxn window operant data... preprocess with roadmap for now if not \n Not able to do GLM mode yet with v3.x \n v3.x not compatible with siITI yet. \n If no exclusions file present, not excluding any trials beyond what was done in initial processing for that dataset.'))
				% 
				% 	For dlight stim/nostim, use:
				% 		obj = CLASS_photometry_roadmapv1_4('v3x', 'times', 17, {'MultiBaseline', 10}, 30000, [], [], stimMode)
				% 
				if nargin < 2
					Mode = 'times';
				end
				if nargin < 3
					nbins = 17;
				end
				if nargin < 4
					gfitStyle = {'box', 200000};
				else
					gfitStyle = gfit;
				end
				if nargin < 5
					timePad = 15000;
				else
					timePad = gtimes;	
				end
				if nargin < 6
					stimMode = 'off';
					disp('		** STIM MODE IS OFF **')
				end
				divideByNTrialsPerBin = true; % resolved 6-20-19 - now is working properly!

				obj.init_v3x(Mode, nbins, gfitStyle, timePad, stimMode, divideByNTrialsPerBin);

				alert = cell2mat(['Stat Obj Complete: ' obj.iv.signalname]); 
			    mailAlert(alert);
			elseif isstr(data) && strcmpi(data, 'stimNphot')
				warning('off','MATLAB:Figure:FigureSavedToMATFile')
				if nargin < 2
					Mode = 'times';
				end
				if nargin < 3
					nbins = 1;
				end
				if nargin < 4
					gfitStyle = {'box', 200000};
				else
					gfitStyle = gfit;
				end
				if nargin < 5
					timePad = 15000;
				else
					timePad = gtimes;	
				end
				obj.initStimNPhotObj(Mode, nbins, gfitStyle, timePad, stimMode);
				savegfit(obj)
			else
				warning('off','MATLAB:Figure:FigureSavedToMATFile')
				obj.SaveMode = true;

				if nargin < 7
					xTimes = [];
				end
				if nargin < 6
					xRaw = [];
				end
				if nargin < 5
					gtimes = [];
				end
				if nargin < 4
					gfit = [];
				end 
				if nargin < 1
					obj.Plot = {};
					iv = {};			
					Mode  = {};
					BinParams  = {};
					BinnedData = {};
					SaveMode = 1;
					Log = {};
					Stat = {};
					Stim = {};
					ChR2 = {};
					GLM = {};
					Listeners = {};
					disp('Created empty object. Returning.')
					return
				end
				if strcmpi(Mode, 'outcome')
					nbins = 6;
				end
				% 
				% 	Now generate the log
				% 
				obj.Log = {};
				obj.generateLog();
				obj.updateLog(['Created Log. (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Init gFit container
				% 
				obj.gFitLP = {};
				% 
				% 	Collect plot references from init_variables
				% 
				data = obj.getPlot(data);
				obj.updateLog(['Acquired plot references. (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Collect the relevant init_variables
				% 
				obj.getInit(data.init_variables, gfit, gtimes, xRaw, xTimes, data);
				if strcmp(obj.iv.setStyle, 'combined')
	                obj.iv.dataset_map = data.dataset_map;
	            end
				obj.iv.exclusions_struct = data.exclusions_struct;
				obj.updateLog(['Acquired init_variables. (' datestr(now,'HH:MM AM') ') \n']);
				% 
				obj.BinParams.ogBins = nbins;
				obj.Mode = Mode;
				% 
				% 	Determine if this is a combined stim/phot object
				% 
				obj.Stim.stimobj = isfield(data.init_variables, 'photNstim') && data.init_variables.photNstim;
				if obj.Stim.stimobj
					[file,path] = uigetfile('*.mat', 'Select ChR2 pre-processed file');
					obj.ChR2 = load([path, file]);
	                field = fieldnames(obj.ChR2);
	                obj.ChR2 = getfield(obj.ChR2, field{1});
				else
					obj.ChR2 = {};
				end
				% 
				% 	Initialize binning for plots
				% 
				if strcmp(obj.iv.signaltype_, 'camera')
					obj.Plot.smooth_kernel = 3;
					obj.Plot.nbins = nbins;
				elseif strcmp(obj.iv.signaltype_, 'movement')
					obj.Plot.smooth_kernel = 200;
					obj.Plot.nbins = nbins;
				else
					obj.Plot.smooth_kernel = 100;
					obj.Plot.nbins = nbins;
				end
				% 
				% 	Combine data into initial binning, set by nbins (choose large nbins for now, e.g. 17*10 = 170 for 100ms res)
				% 
				obj.updateLog(['\n ------------------------- \n Initiating binning procedure for Mode: ' Mode '. (' datestr(now,'HH:MM AM') ') \n']);
				obj.getBinnedData(data);
				obj.updateLog(['Binning complete. (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	If this object is type accelerometer, go ahead and band-pass the binned data...
				% 
				if strcmp(obj.iv.signaltype_, 'accelerometer')
					obj.bandPassAcc;
					disp('Detected accelerometer data and executed band-pass filtering on the binned data...')
				end
				% 
				% 	Initialize stat container
				% 
				obj.Stat = {};
				% 
				% 	If SaveMode is on, we will immediately save to the directory with timestamp
				% 
				if obj.SaveMode
					timestamp_now = datestr(now,'mm_dd_yy__HH_MM_AM');
					savefilename = [obj.iv.mousename_ '_' obj.iv.signalname '_statObj_Mode' obj.Mode '_' num2str(obj.BinParams.ogBins) 'bins_' timestamp_now];
					save([savefilename, '.mat'], 'obj', '-v7.3');
					obj.updateLog(['Saved initiated object to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat (' datestr(now,'HH:MM AM') ') \n']);
				end
				% 
				obj.updateLog(['Stat object generated and ready to use. ' datestr(now,'HH:MM AM') ') \n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~']);
				% 
				
				
			end
			warning('on','MATLAB:Figure:FigureSavedToMATFile')
		end
		% -----------------------------------------------------
		% 				Initialize init_variables (verified 8/12/18)
		% -----------------------------------------------------
		function getInit(obj, iv, gfit, gtimes, xRaw, xTimes, data, v3x)
			if nargin < 8
				v3x = false;
			end
			if ~v3x
				% 
				%   Pull out only the important init_variables
				% 
				if strcmp(obj.iv.setStyle, 'combined')
					roadmap.setStyle = 'combined';
					roadmap.files = iv.file_addresses; 			% struct of file paths and names
				elseif strcmp(obj.iv.setStyle, 'single-day')
					roadmap.setStyle = 'single-day';
					roadmap.files = iv.analysis_file;
				else
					error('Undefined setStyle -- is this single-day or combined???')
				end
				roadmap.date = iv.todaysdate; 				% '8_10_18'
				roadmap.exptype_ = iv.exptype_; 			% 'op'
				roadmap.rxnwin_ = iv.rxnwin_; 				% 500 ms
				roadmap.total_time_ = iv.trial_duration_;	% 17000 ms
				roadmap.mousename_ = iv.mousename_; 		% 'B5'
				roadmap.gfit_win_ = iv.gfit_win_; 			% 200000
				roadmap.signalname = iv.signalname; 		% 'SNc'
				roadmap.signaltype_ = iv.signaltype_; 		% 'photometry'
				obj.iv = roadmap;
				% 
				obj.iv.num_trials = iv.num_trials;
				% obj.iv.num_si_ITI_licks = iv.num_si_ITI_licks; (obsolete because recalculating with method here)
				obj.iv.num_si_ITI_licks = length(obj.Plot.siITI.Lick.s.wrtCue);
				% 
				%	Initialize GLM Mode 
				% 
				obj.GLM.Mode = false;
				obj.GLM.exclusionsTaken = false;
				% 
				if strcmp(obj.iv.setStyle, 'combined')
					obj.iv.num_trials_category = iv.num_trials_category;  
				elseif strcmp(obj.iv.setStyle, 'single-day')
					obj.iv.num_trials_category.num_rxn_not_ex_trials = sum(data.lick_data_struct.f_ex_lick_rxn > 0);
					obj.iv.num_trials_category.num_early_not_ex_trials = sum(data.lick_data_struct.f_ex_lick_operant_no_rew > 0);
					obj.iv.num_trials_category.num_rew_not_ex_trials = sum(data.lick_data_struct.f_ex_lick_operant_rew > 0);
					obj.iv.num_trials_category.num_ITI_not_ex_trials = sum(data.lick_data_struct.f_ex_lick_ITI > 0);
					obj.iv.num_trials_category.num_trials_category.num_no_ex_trials = obj.iv.num_trials_category.num_rxn_not_ex_trials + obj.iv.num_trials_category.num_early_not_ex_trials + obj.iv.num_trials_category.num_rew_not_ex_trials + obj.iv.num_trials_category.num_ITI_not_ex_trials;
					obj.iv.num_trials_category.num_no_rxn_or_ex_trials = obj.iv.num_trials_category.num_trials_category.num_no_ex_trials - obj.iv.num_trials_category.num_rxn_not_ex_trials;
					% 
					% 	Gather GLM variables, too
					% 
					disp('	Gathering GLM variables...')
					obj.GLM.Mode = true;
					obj.GLM.lampOff_s = iv.trial_start_times;
					obj.GLM.cue_s = iv.cue_on_times;
					obj.GLM.lampOn_s = iv.lampOn_times;
					obj.GLM.lampOn_s = iv.lampOn_times;
					obj.GLM.lick_s = iv.lick_times;
					warning('GLM not suitable for non-0ms rxn time. Have not designed to calculate first lick with non-zero rxn window.')
					[~, ~, lick_events] = histcounts(obj.GLM.lick_s, obj.GLM.cue_s);
					[obj.GLM.fLick_trial_num, idx_event, ~] = unique(lick_events);
					if obj.GLM.fLick_trial_num(1) == 0
						obj.GLM.fLick_trial_num = obj.GLM.fLick_trial_num(2:end);
						idx_event = idx_event(2:end);
					end
					warning('I think below is wrong.')
					obj.GLM.firstLick_s = obj.GLM.lick_s(idx_event);
					obj.getFirstLickCategory();
					% 
					% 	GLM signals
					% 
					answer = questdlg('Detected single-day data. Collect GLM variables from file?','GLM?','No')
					if strcmp(answer, 'Yes')
						if ~isempty(gfit) && ~isstruct(gfit) && ~isstruct(gtimes)
							obj.GLM.gfit = gfit;
							obj.GLM.gtimes  = gtimes;
						else
							disp('	Select the gfit structure to use')
							gfitStruct = obj.pullVarFromBaseWorkspace('Select gfit struct');
							if isempty(gfitStruct)
								[gfile,gpath] = uigetfile('*.mat','Select the gfit structure to use');
		                        if isempty(gfile) || isempty(gpath)
		                            gfitStruct = [];
		                            obj.GLM.gfit  = [];
		                            disp('Not using gfit! No stats!')
		                        else
		                            gfitStruct = load([gpath,gfile]);
		                            f = fieldnames(gfitStruct);
		                            gfitStruct = getfield(gfitStruct, f{1});
		                            obj.GLM.gfit  = gfitStruct.gfit_signal;
		                        end
		                    else
		                        obj.GLM.gfit  = gfitStruct.gfit_signal;
		                    end
							% 
							% 
							% 
							disp('	Select the signal structure to get times')
							gStruct = obj.pullVarFromBaseWorkspace(['Select ' obj.iv.signalname ' struct from workspace']);
							if isempty(gStruct)
								[gfile,gpath] = uigetfile('*.mat','Select the whole-day structure to get times');
		                        if isempty(gfile) && isempty(gpath)
		                           gStruct.times =[];
		                           gStruct.values =[];
		                        else
		                            sigStruct = load([gpath,gfile]);
		                            f = fieldnames(sigStruct);
		                            fidx = find(cellfun(@(x) contains(x,obj.iv.signalname), f)>0);
		                            gStruct = getfield(sigStruct, f{fidx});
		                        end
		                	end
							obj.GLM.gtimes  = gStruct.times;
						end
						if ~isempty(xRaw) && ~isempty(xTimes)
							obj.addX(xRaw, xTimes);
		                else
		                	if exist('f', 'var')
			                    fidx = find(cellfun(@(x) contains(x,'X'), f)>0);
			                    if ~isempty(fidx)
			                        xStruct = getfield(sigStruct, f{fidx});
			                        xRaw = xStruct.values;
			                        xTimes = xStruct.times;
			                        obj.addX(xRaw, xTimes);
			                    else
			                        fidx = find(cellfun(@(x) contains(x,'EMG'), f)>0);
			                        if ~isempty(fidx)
			                            emgStruct = getfield(sigStruct, f{fidx});
			                            emgRaw = emgStruct.values;
			                            emgTimes = emgStruct.times;
			                            obj.addEMG(emgRaw, emgTimes);
			                        else
			                            warning('No movement signals detected... Will not be able to use in GLM models')
			                        end
			                    end	
		                    else
		                    	disp('	Select the X structure')
								xStruct = obj.pullVarFromBaseWorkspace(['Select X struct from workspace']);
								if isempty(xStruct)
									disp('	No X structure. Select EMG structure')
									emgStruct = obj.pullVarFromBaseWorkspace(['Select EMG struct from workspace']);
		                            if isempty(emgStruct)
		                                disp('No movement structures!')
		                            else
		                                emgRaw = emgStruct.values;
		                                emgTimes = emgStruct.times;
		                                obj.addEMG(emgRaw, emgTimes);
		                            end
								else
									xRaw = xStruct.values;
			                        xTimes = xStruct.times;
			                        obj.addX(xRaw, xTimes);
			                	end
		                	end
						end
					end
				end
				obj.updateLog(['Detected mouse: ' obj.iv.mousename_ ' || signal: ' obj.iv.signalname ' || num_trials: ' num2str(obj.iv.num_trials) ' (' datestr(now,'HH:MM AM') ') \n']);
			else
				gfitStyle = gfit;
				timePad = gtimes;
				obj.iv.date = datestr(now);
				obj.iv.exptype_ = 'op';
				obj.iv.rxnwin_ = 0;
				if ~isfield(obj.iv, 'BingoMODE') || ~obj.iv.BingoMODE
					obj.iv.total_time_ = 17000;
				else
					obj.iv.total_time_ = 20000;
				end
				obj.iv.mousename_ = ''; % fill in as we add data...
				if strcmpi(gfitStyle{1}, 'box')
					obj.iv.gfit_box_win_ = gfitStyle{2};
					obj.GLM.gfitMode = ['box', num2str(obj.iv.gfit_box_win_)];
				elseif strcmpi(gfitStyle{1}, 'multibaseline')
					obj.iv.gfit_multibaseline_ntrials_ = gfitStyle{2};
					obj.GLM.gfitMode = [num2str(obj.iv.gfit_multibaseline_ntrials_ ), 'trial norm multi baseline';];
				elseif strcmpi(gfitStyle{1}, 'ChR2')
					obj.GLM.gfitMode = 'ChR2';
				else % assume raw F...
					warning('gfit style undefined, using raw F')
					obj.iv.gfit = 'using raw F';
					obj.GLM.gfitMode = 'rawF';
				end				
				% 
				%	Initialize GLM Mode 
				% 
				obj.GLM.Mode = false;
				% obj.GLM.exclusionsTaken = false;
				% 
				%	Initialize containers for trial numbers 
				% 
				obj.iv.num_trials = 0;
				obj.iv.num_trials_category.num_no_ex_trials = 0;
				obj.iv.num_trials_category.num_no_rxn_or_ex_trials = 0;
				obj.iv.num_trials_category.num_rxn_not_ex_trials = 0;
				obj.iv.num_trials_category.num_early_not_ex_trials = 0;
				obj.iv.num_trials_category.num_rew_not_ex_trials = 0;
				obj.iv.num_trials_category.num_ITI_not_ex_trials = 0;
				% 
				if ~isfield(obj.iv, 'ctrl_signaltype_') || isempty(obj.iv.ctrl_signaltype_)
					obj.iv.ctrl_signaltype_{1} = 'none';
				end
				obj.updateLog(['Signals Allowed: ' strjoin(obj.iv.signalname) ' || Control Signals ' strjoin(obj.iv.ctrl_signaltype_) ' (' datestr(now,'HH:MM AM') ') \n']);
			end
		end
		% ----------------------------------------------------
		% 	Initialize Version 3.x
		% ----------------------------------------------------
		function init_v3x(obj, Mode, nbins, gfitStyle, timePad, stimMode, divideByNTrialsPerBin)
			useZScore = false; % I changed this on 6/20/19 because I think the Z scoring is causing artifactual scaling.
			obj.SaveMode = true; % in this case, will save intermediate objects in case of crash in the middle of processing...
			if ~isfield(obj.iv, 'BingoMODE')
				obj.iv.BingoMODE = false; % use with the 20-s total time version of task, 7.5s target, note there's a second place you have to change this to true for 7.5s v
				% note there's a second place you need to set this to true for 7.5s target
			end
			% 
			% 	Now generate the log
			% 
			obj.Log = {};
			obj.generateLog();
			obj.updateLog(['Created Log. (' datestr(now,'HH:MM AM') ') \n']);
			% 
			%	User should select a folder of files with all the data that will be used. 
			% 	To generate files, we should have access to the original day's data, the gfit stuct (if we will use it), and the processed data struct
			% 		If any of these is not available, we can work just from the original day's data - we just need to calc gfit as we prefer and 
			% 		then we will figure out the rest
			%
		 	%	1. Request user to select directory with subfolders 
		 	% 
		 	obj.iv.signalname = '';
			fn = {'SNc', 'DLS', 'VTA', 'DLSright', 'DLSleftD', 'SNcred', 'VTAred', 'DLSred', 'EMG', 'X', 'Y', 'Z', 'CamO', 'ChR2', 'SNcnovir', 'VTAnovir', 'SNcgreen', 'VTAgreen', 'DLSgreen', 'NAc', 'NAcred'};			
			idxrg_phot = [1:5, 20];
			idxrg_ctrlphit = [6:8, 15, 16, 17, 18, 19, 21];
			idxrg_move = [9:13];
			idxrg_stim = [14];
			mydlg = msgbox(sprintf('Version 3.x Instructions: \n\n 1. Create a directory with all files to include in object. \n\n 2. In directory, make a folder containing each file set to include. Minimum is the spike2 file, but can include gfit and processed data structs as shortcuts if desired. \n 3. If you select only a movement signal, it will process singly, otherwise you can include control signals in the CtrlChannel field by selecting a signal type and a movement type. \n 4. If multiple signal types are selected that are photometry, they will be averaged and binned together as if they are the same. \n\n\n *** Note: If you select ChR2 ONLY, this will initialize a v3.9 Optogenetics object that will use all available control signals and do AUTORUN_optogenetics_postprocessing_roadmapv1_4.'));
			uiwait(mydlg);
			[indx,~] = listdlg('PromptString','Select data type(s) to include...',...
			                           'ListString',fn);
			if isempty(indx)
				disp('cancelled.')
				return
			elseif numel(indx) == 1
				obj.iv.signalname = fn(indx);
				if ismember(indx, idxrg_phot) || ismember(indx, idxrg_ctrlphit)
					obj.iv.signaltype_ = 'photometry';
				elseif ismember(indx, idxrg_move)
					if indx == idxrg_move(1)
						obj.iv.signaltype_ = 'EMG';
						disp('Switching to rect-only EMG gfit style')
						% gfitStyle = {'Abs-hipass-EMG', []};
						gfitStyle = {'EMG', []};
					elseif ismember(indx, idxrg_move(2:4))
						obj.iv.signaltype_ = 'accelerometer';
						disp('Switching to Abs-bandpass-X gfit style')
						gfitStyle = {'Abs-X', []};
						% disp('Switching to Abs-Xderivative gfit style')
						% gfitStyle = {'Abs-Xderivative', []};
					elseif indx == idxrg_move(5)
						obj.iv.signaltype_ = 'camera';
						disp('Switching to Abs-CamOderivative gfit style')
						gfitStyle = {'Abs-CamOderivative', []};
						obj.iv.camoFs = gfitStyle{2};
						warning(['The sampling freq is ' num2str(obj.iv.camoFs) 'fps'])
					end
				elseif ismember(indx, idxrg_stim)
					% 
					% 	Determine if this is a combined stim/phot object
					% 
					obj.iv.signaltype_ = 'optogenetics';
					obj.Stim.stimobj = true;
					obj.ChR2 = {};
					gfitStyle = {'ChR2', []};
					warning('Entering Optogenetics v3.x Mode!----------------------------------------------')
					% 
					% 	The control signal is automatically now ChR2 since we will use this to chop up the data...
					% 
				end		
				obj.iv.ctrl_signaltype_ = {'none'};			
			elseif numel(indx) > 1 
				% 
				% 	The first signal will be the photometry signal of interest. If there's more than one photom signal of interest, we will include both
				% 
				obj.iv.signalname = fn(indx(1));
				obj.iv.signaltype_ = 'photometry';
				for idx = 2:numel(indx)
					if ismember(indx(idx), idxrg_phot)
						obj.iv.signalname(idx) = fn(indx(idx));
					elseif ismember(indx(idx), idxrg_ctrlphit)
						obj.iv.ctrl_signalname(idx-1) = fn(indx(idx));
						obj.iv.ctrl_signaltype_(idx-1) = 'photometry';	
					elseif ismember(indx(idx), idxrg_move)
						if indx(idx) == idxrg_move(1)
							obj.iv.ctrl_signalname(idx-1) = fn(indx(idx));
							obj.iv.ctrl_signaltype_(idx-1) = 'EMG';
						elseif ismember(indx(idx), idxrg_move(2:4))
							obj.iv.ctrl_signalname(idx-1) = fn(indx(idx));
							obj.iv.ctrl_signaltype_(idx-1) = 'accelerometer';
						elseif indx(idx) == idxrg_move(5)
							obj.iv.ctrl_signalname(idx-1) = fn(indx(idx));
							obj.iv.ctrl_signaltype_(idx-1) = 'camera';
						end
					elseif ismember(indx(idx), idxrg_stim)
						% 
						% 	Determine if this is a combined stim/phot object
						% 
						obj.Stim.stimobj = true;
						obj.ChR2 = {};
						warning('Make sure you acquired proper ChR2 file...')
					end
				end
			end
			hostFolder = uigetdir('','Select host folder');
			cd(hostFolder)
			hostFiles = dir(hostFolder);
			dirFlags = [hostFiles.isdir];
			subFolders = hostFiles(dirFlags);
			folderNames = {subFolders(3:end).name};
			folderPaths = {subFolders(3:end).folder};
			obj.iv.files = folderNames;
			obj.updateLog([strjoin(['The following datasets will be loaded: ' folderNames]) '\n']);
			% 
			% 	We will start by initializing all the params for the object, as we usually do. We will constrain all the loaded files to match these params
			% 
			%	Certain params will be specified at outset, here: 
			% 
			obj.updateLog('Using default trial parameters. If trial length or times is different from standard, update here...')
			if numel(folderNames) < 1
				error('No subfolders! v3x needs a subfolder for each file to process and include in the data object')
			end
			obj.getInit([], gfitStyle, timePad, [], [], [], true);
			% 
			% 	Collect plot references from init_variables
			% 
			obj.getPlot([], true);
			% 
			obj.BinParams.ogBins = nbins;
			obj.GLM.isSingleSeshObj = false;
			obj.GLM.exclusionsTaken = false;
			% 
			%	Now, for each fileset in the directory, extract its info and append it to the running ave binned data... 
			% 
			% cPcp = 0;
			% cCtrl = 0;
			for iset = 1:numel(folderNames)
                cd(folderNames{iset})
				% 
				% 	Indicate that we are initializing processing for the current subfolder
				% 	
				obj.updateLog(['=====>>> Processing Data for folder ' folderNames{iset} ' (' num2str(iset) '/' num2str(numel(folderNames)) ' ' datestr(now,'HH:MM AM') ') =================== \n']);
				% 
				% 	Check what info is available to us in the subfolder. If we want a box200 gfit, we need to load the gfit. If exclusions are present we will add them
				% 
				dirFiles = dir;
				% 
				% 	First, check if a statObj is already present:
				% 
				sObjpos = find(contains({dirFiles.name},'sObj'));
				if isempty(sObjpos)
					sObjpos = find(contains({dirFiles.name},'snpObj'));
					if isempty(sObjpos)
						sObjpos = find(contains({dirFiles.name},'statObj'));
					end
				end
				if ~isempty(sObjpos) && numel(sObjpos) < 2
					obj.updateLog('		Detected statObj in folder')
					sObj = load([dirFiles(sObjpos).folder, '\' dirFiles(sObjpos).name]);
                    sObjfield = fieldnames(sObj);
                    eval(['sObj = sObj.' sObjfield{1} ';']);
				else
					obj.updateLog('		No statObj in folder or too many! Processing data from scratch to create a sObj')
					sObj = CLASS_photometry_roadmapv1_4('stimNphot', 'times', 1, gfitStyle, timePad, [], [], stimMode);
				end
				% 
				% 	Check that the sObj has all the necessary components and correct gfits as needed
				% 
				if ~isfield(sObj.GLM, 'gfit') && strcmp(obj.iv.signaltype_, 'photometry') && ~strcmp(sObj.Mode, 'v3x Combined Datasets')
					obj.updateLog('sObj has no gfit! Acquiring from file...')
					if strcmpi(gfitStyle{1}, 'box')
						% 
						% 	Check for a gfit file in the folder
						% 
						gfitPos = find(contains({dirFiles.name},'gfit'));
						%	 
						%  If not the right kind of gfit in the sObj, acquire it from file
						%
						if isempty(gfitPos) && (isfield(sObj.GLM, 'gfitMode') && ~strcmp(sObj.GLM.gfitMode,['box', num2str(obj.iv.gfit_box_win_)]))
							disp('		could not load gfit rv1.4 file and/or wrong type in sObj, redoing from spike2file')
							s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
							s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
							signals = fieldnames(s7s);
							% 
							% 	Once in the spike 2 file, extract anything relevant for actual signals...
							% 
							fieldIdx = contains(signals, 'Start_Cu');
							eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lick');
							eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lamp_OFF');
							eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, obj.iv.signalname);
							eval(cell2mat(['sObj.GLM.rawF = s7s.' signals(fieldIdx) '.values;']));
							eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
							
							sObj.GLM.gfit = gfitBox(sObj.GLM.rawF, gfitfields{2});
							sObj.GLM.gfitMode = ['box', num2str(obj.iv.gfit_box_win_)];

						else % if we do have the gfit file preprocessed in the directory, load it up
							gfitstruct = load([dirFiles(gfitPos).folder, '\', dirFiles(gfitPos).name]);
							gfitfields = fieldnames(gfitstruct);
							try
								eval(['sObj.GLM.gfit = gfitstruct.' gfitfields{1} '.gfit_signal;'])
								obj.updateLog('		gfit box200 acquired from rv1.4 file')
								s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
								s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
								signals = fieldnames(s7s);
								% 
								% 	Once in the spike 2 file, extract anything relevant for actual signals...
								% 
								fieldIdx = contains(signals, 'Start_Cu');
								eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
								fieldIdx = contains(signals, 'Lick');
								eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
								fieldIdx = contains(signals, 'Lamp_OFF');
								eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
								fieldIdx = contains(signals, obj.iv.signalname);
								eval(cell2mat(['sObj.GLM.rawF = s7s.' signals(fieldIdx) '.values;']));
								eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
							catch
								warning('		could not load gfit rv1.4 file, redoing from spike2file')
								s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
								s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
								signals = fieldnames(s7s);
								% 
								% 	Once in the spike 2 file, extract anything relevant for actual signals...
								% 
								fieldIdx = contains(signals, 'Start_Cu');
								eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
								fieldIdx = contains(signals, 'Lick');
								eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
								fieldIdx = contains(signals, 'Lamp_OFF');
								eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
								fieldIdx = contains(signals, obj.iv.signalname);
								eval(cell2mat(['sObj.GLM.rawF = s7s.' signals(fieldIdx) '.values;']));
								eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
								sObj.GLM.gfit = gfitBox(sObj.GLM.rawF, gfitfields{2});
								sObj.GLM.gfitMode = ['box', num2str(obj.iv.gfit_box_win_)];
							end
						end
					elseif strcmpi(gfitStyle{1}, 'multibaseline') 
						if ~isfield(sObj.GLM, 'rawF')
							obj.updateLog('		No rawF signal in the statObj. Need to get from spike2 file')
							s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
							s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
							signals = fieldnames(s7s);
							% 
							% 	Once in the spike 2 file, extract anything relevant for actual signals...
							% 
							fieldIdx = contains(signals, 'Start_Cu');
							eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lick');
							eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lamp_OFF');
							eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, obj.iv.signalname);
							eval(cell2mat(['sObj.GLM.rawF = s7s.' signals(fieldIdx) '.values;']));
							eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
						end
						% 
						% 	Check if it's already correct
						% 
						sObj.redoNMBgfitChR2(gfitStyle{2});
						obj.updateLog('		Redid the NMB gfit for this sObj')
					end
					% 
					% 	Since we went to the effort to redo it, save the new sObj to the file
					% 
					obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
					save('sObj_Corrected.mat', 'sObj', '-v7.3');
					% 
				elseif strcmpi(gfitStyle{1}, 'Abs-X')
					% 
					% 	Take derivative with bandpass
					% 
					warning('RBF')
					if isfield(sObj.GLM, 'gfitMode') && strcmpi(sObj.GLM.gfitMode, 'Abs-X') && isfield(sObj.GLM, 'gfit')
						obj.updateLog('Using Abs-X gfit from file')
					else
						if isfield(sObj.GLM, 'X')
							obj.updateLog('	Correcting X -- taking raw X, bandpassing and rectifying')
							sObj.GLM.gfit = abs(sObj.bandPass(sObj.GLM.X));
							sObj.GLM.gfitMode = 'Abs-X';

						elseif isfield(sObj.GLM, 'gX')
							obj.updateLog('	Correcting X -- rectifying gX')
							sObj.GLM.gfit = abs(sObj.GLM.gX); 
							sObj.GLM.gfitMode = 'Abs-X';
						else
							obj.updateLog('		No appropriate abs-X gfit signal in the statObj. Collecting Abs-X from spike2 file')
							s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
							s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
							signals = fieldnames(s7s);
							% 
							% 	Once in the spike 2 file, extract anything relevant for actual signals...
							% 
							fieldIdx = contains(signals, 'Start_Cu');
							eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lick');
							eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lamp_OFF');
							eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, obj.iv.signalname);
							eval(cell2mat(['sObj.GLM.X = s7s.' signals(fieldIdx) '.values;']));
							eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
							sObj.GLM.gfit = abs(sObj.bandPass(sObj.GLM.X));
							sObj.GLM.gfitMode = 'Abs-X';
						end
						% 
						% 	Since we went to the effort to redo it, save the new sObj to the file
						% 
						obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
						save('sObj_Corrected.mat', 'sObj', '-v7.3');
					end
				elseif strcmpi(gfitStyle{1}, 'Abs-Xderivative')
					% 
					% 	Take derivative with bandpass
					% 
					warning('RBF')
					if isfield(sObj.GLM, 'gfitMode') && strcmpi(sObj.GLM.gfitMode, 'Abs-Xderivative') && isfield(sObj.GLM, 'gfit')
						obj.updateLog('Using Abs-Xderivative gfit from file')
					else
						if isfield(sObj.GLM, 'X')
							obj.updateLog('	Correcting X -- taking raw X, derivative and rectifying')
							sObj.GLM.gfit = [0;abs(sObj.GLM.X(2:end)-sObj.GLM.X(1:end-1))];
							sObj.GLM.gfitMode = 'Abs-Xderivative';
						else
							obj.updateLog('		No appropriate Abs-Xderivative signal in the statObj. Collecting Abs-Xderivative from spike2 file')
							s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
							s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
							signals = fieldnames(s7s);
							% 
							% 	Once in the spike 2 file, extract anything relevant for actual signals...
							% 
							fieldIdx = contains(signals, 'Start_Cu');
							eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lick');
							eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, 'Lamp_OFF');
							eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
							fieldIdx = contains(signals, obj.iv.signalname);
							eval(cell2mat(['sObj.GLM.X = s7s.' signals(fieldIdx) '.values;']));
							eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
							sObj.GLM.gfit = [0;abs(sObj.GLM.X(2:end)-sObj.GLM.X(1:end-1))];
							sObj.GLM.gfitMode = 'Abs-Xderivative';
						end
						% 
						% 	Since we went to the effort to redo it, save the new sObj to the file
						% 
						obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
						save('sObj_Corrected.mat', 'sObj', '-v7.3');
					end

						
				elseif strcmpi(gfitStyle{1}, 'Abs-bandpass-EMG')
					% 
					% 	Take derivative with bandpass
					% 
					warning('RBF')
					if isfield(sObj.GLM, 'gfitMode') && strcmpi(sObj.GLM.gfitMode, 'Abs-bandpass-EMG') && isfield(sObj.GLM, 'gfit')
						obj.updateLog('Using Abs-bandpass-EMG gfit from file')
					else
						obj.updateLog('		No appropriate Abs-bandpass-EMG gfit signal in the statObj. Collecting Abs-bandpass-EMG from spike2 file')
						s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
						s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
						signals = fieldnames(s7s);
						% 
						% 	Once in the spike 2 file, extract anything relevant for actual signals...
						% 
						fieldIdx = contains(signals, 'Start_Cu');
						eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lick');
						eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lamp_OFF');
						eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, obj.iv.signalname);
						eval(cell2mat(['sObj.GLM.EMG = s7s.' signals(fieldIdx) '.values;']));
						eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
						sObj.GLM.gfit = abs(sObj.bandPass(sObj.GLM.EMG));
						sObj.GLM.gfitMode = 'Abs-bandpass-EMG';
						% 
						% 	Since we went to the effort to redo it, save the new sObj to the file
						% 
						obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
						save('sObj_Corrected.mat', 'sObj', '-v7.3');
					end
				elseif strcmpi(gfitStyle{1}, 'Abs-hipass-EMG')
					% 
					% 	Take derivative with bandpass
					% 
					warning('RBF')
					if isfield(sObj.GLM, 'gfitMode') && strcmpi(sObj.GLM.gfitMode, 'Abs-hipass-EMG') && isfield(sObj.GLM, 'gfit')
						obj.updateLog('Using Abs-hipass-EMG gfit from file')
					else
						obj.updateLog('		No appropriate Abs-hipass-EMG gfit signal in the statObj. Collecting Abs-hipass-EMG from spike2 file')
						s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
						s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
						signals = fieldnames(s7s);
						% 
						% 	Once in the spike 2 file, extract anything relevant for actual signals...
						% 
						fieldIdx = contains(signals, 'Start_Cu');
						eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lick');
						eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lamp_OFF');
						eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, obj.iv.signalname);
						eval(cell2mat(['sObj.GLM.EMG = s7s.' signals(fieldIdx) '.values;']));
						eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
						sObj.GLM.gfit = abs(sObj.hiPass(sObj.GLM.EMG));
						sObj.GLM.gfitMode = 'Abs-hipass-EMG';
						% 
						% 	Since we went to the effort to redo it, save the new sObj to the file
						% 
						obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
						save('sObj_Corrected.mat', 'sObj', '-v7.3');
					end
				elseif strcmpi(gfitStyle{1}, 'EMG')
					% 
					% 	Take derivative with bandpass
					% 
					warning('RBF')
					if isfield(sObj.GLM, 'gfitMode') && strcmpi(sObj.GLM.gfitMode, 'EMG') && isfield(sObj.GLM, 'gfit')
						obj.updateLog('Using Rectified EMG gfit from file')
					else
						obj.updateLog('		No appropriate rectified EMG gfit signal in the statObj. Collecting EMG from spike2 file')
						s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
						s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
						signals = fieldnames(s7s);
						% 
						% 	Once in the spike 2 file, extract anything relevant for actual signals...
						% 
						fieldIdx = contains(signals, 'Start_Cu');
						eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lick');
						eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lamp_OFF');
						eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, obj.iv.signalname);
						eval(cell2mat(['sObj.GLM.EMG = s7s.' signals(fieldIdx) '.values;']));
						eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
						sObj.GLM.gfit = abs(sObj.GLM.EMG);
						sObj.GLM.gfitMode = 'EMG';
						% 
						% 	Since we went to the effort to redo it, save the new sObj to the file
						% 
						obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
						save('sObj_Corrected.mat', 'sObj', '-v7.3');
					end
				elseif strcmpi(gfitStyle{1}, 'ChR2')
					% 
					% 	Take derivative with bandpass
					% 
					warning('RBF')
					if isfield(sObj.GLM, 'gfitMode') && strcmpi(sObj.GLM.gfitMode, 'ChR2') && isfield(sObj.GLM, 'gfit')
						obj.updateLog('ChR2 gfit from file (just the ChR2 waveform)')
					else
						obj.updateLog('		No appropriate rectified ChR2 gfit signal in the statObj. Collecting ChR2 from spike2 file')
						s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'obj')) + 2;
						s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
						signals = fieldnames(s7s);
						% 
						% 	Once in the spike 2 file, extract anything relevant for actual signals...
						% 
						fieldIdx = contains(signals, 'Start_Cu');
						eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lick');
						eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lamp_OFF');
						eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, obj.iv.signalname);
						eval(cell2mat(['sObj.GLM.ChR2 = s7s.' signals(fieldIdx) '.values;']));
						eval(cell2mat(['sObj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
						sObj.GLM.gfit = abs(sObj.GLM.ChR2);
						sObj.GLM.gfitMode = 'ChR2';
						% 
						% 	Since we went to the effort to redo it, save the new sObj to the file
						% 
						obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
						save('sObj_Corrected.mat', 'sObj', '-v7.3');
					end
				elseif strcmpi(gfitStyle{1}, 'Abs-CamOderivative')
					if ~isfield(sObj.GLM, 'gfit') || ~strcmpi(sObj.GLM.gfitMode, 'Abs-CamOderivative')
		                error('Not implemented - will need to add s7s stuff before this portion if you need to run it. Never should need to though')
		                % 
						% 	Check if approp gfit is already in the folder:
						% 
						% 
		                dirFiles = dir;
						gfitPos = find(contains({dirFiles.name},'processed'));
						%	 
						%  If not the right kind of gfit in the sObj, acquire it from file
						%
						if isempty(gfitPos)
							disp('		could not load gfit rv1.4 file and/or wrong type in folder, redoing from spike2file')
		                    sObj.GLM.gfit = abs(sObj.gfitCamera(sObj.GLM.CamOtimes, sObj.GLM.IRtrig));
		                    % 
		                    %	Append nans to the front before the camera trigger 
		                    % 
		                    nanpad = nan(1, find(sObj.GLM.CamOtimes > sObj.GLM.IRtrig, 1, 'first')-1);
		                    sObj.GLM.gfit = [nanpad, sObj.GLM.gfit];
		                    %
		                    %   Chop the ChR2 times
		                    %
		                    if ignoreStim
		                        error('RBF')
		                        sObj.GLM.gfit(sObj.GLM.pos.ChR2) = nan;
		                    end
							sObj.GLM.gfitMode = 'Abs-CamOderivative';
							% 
						else % if we do have the gfit file preprocessed in the directory, load it up
							% 
							gfitstruct = load([dirFiles(gfitPos).folder, '\', dirFiles(gfitPos).name]);
							gfitfields = fieldnames(gfitstruct);
							try
								eval(['sObj.GLM.gfit = abs(gfitstruct.' gfitfields{1} '.derivativeSignal);'])
								% 
			                    %	Append nans to the front before the camera trigger 
			                    % 
			                    nanpad = nan(1, find(sObj.GLM.CamOtimes > sObj.GLM.IRtrig, 1, 'first')-1);
			                    sObj.GLM.gfit = [nanpad, sObj.GLM.gfit];
								% video_struct.derivativeSignal
		                        if ignoreStim
		                            error('RBF')
		                            sObj.GLM.gfit(sObj.GLM.pos.ChR2) = nan;
		                        end
								sObj.updateLog('		gfit camera derivative acquired from rv1.4 file')
								sObj.GLM.gfitMode = 'Abs-CamOderivative';
							catch
								warning('		could not load gfit rv1.4 file, redoing from spike2file')
								sObj.GLM.gfit = abs(sObj.gfitCamera(sObj.GLM.CamOtimes, sObj.GLM.IRtrig));
								% 
			                    %	Append nans to the front before the camera trigger 
			                    % 
			                    nanpad = nan(1, find(sObj.GLM.CamOtimes > sObj.GLM.IRtrig, 1, 'first')-1);
			                    sObj.GLM.gfit = [nanpad, sObj.GLM.gfit];
		                        if ignoreStim
		                            error('RBF')
		                            sObj.GLM.gfit(sObj.GLM.pos.ChR2) = nan;
		                        end
								sObj.GLM.gfitMode = 'Abs-CamOderivative';
							end
						end
						% 
						% 	Since we went to the effort to redo it, save the new sObj to the file
						% 
						sObj.GLM.gfitMode = 'Abs-CamOderivative';
						obj.updateLog(['Saving the corrected sObj to folder (' datestr(now,'HH:MM AM') ') '])
						save('sObj_Corrected.mat', 'sObj', '-v7.3');
					else
						obj.updateLog(['Proper gfit already in file for Abs-CamOderivative. Proceeding'])
					end
                elseif ~strcmpi(sObj.iv.signaltype_, 'photometry')
					error('Must specify correct gfit style for datatype')
				end				
				% 
				% 	Load Exclusions Variable -- only need this to add more exclusions than you originally used
				% 
				excPos = find(contains({dirFiles.name},'exclusions'));
				if ~isempty(excPos)
					exclusionsFile = fileread([dirFiles(excPos).folder, '\', dirFiles(excPos).name]);
				else
					error('Need to put in exclusion file for autoloader!')
				end
				% excPos = find(contains({dirFiles.name},'exclusions'));
				% if ~isempty(excPos)
				% 	exclusionsFile = load([dirFiles(excPos).folder, '\', dirFiles(excPos).name]);
				% else
				% 	exclusionsFile = [];
				% end
				% 
				% 	Now, if this is a single-sesh sObj, let's get the binned data and update the new obj. Otherwise, let's just grab the binned data
				% 
				if isfield(sObj.iv, 'setStyle') && strcmp(sObj.iv.setStyle, 'v3x Combined Datasets')
					% 
					% 	This data is already binned up. 
					% 	
					error('not implemented')
                elseif ~isempty(exclusionsFile) && ~isfield(sObj.GLM, 'fLick_trial_num')
					% 
					% 	We will redo ALL exclusions now. Have to redo everything because otherwise the prior exclusions on the Obj will screw up our timestamps
					% 
					exclusionsFile = [sObj.iv.exclusions_struct.Excluded_Trials, exclusionsFile];
					% 
					% 	Pop these in GLM
					% 
					if ~exist('s7s')
						s7spos = find(~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'processed') & ~contains({dirFiles(3:end).name},'obj')) + 2;
						s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
						signals = fieldnames(s7s);
						fieldIdx = contains(signals, 'Start_Cu');
						eval(cell2mat(['sObj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lick');
						eval(cell2mat(['sObj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
						fieldIdx = contains(signals, 'Lamp_OFF');
						eval(cell2mat(['sObj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
					end			
					[~, ~, lick_events] = histcounts(sObj.GLM.lick_s, sObj.GLM.cue_s);
					[fLick_trial_num, idx_event, ~] = unique(lick_events);
					if fLick_trial_num(1) == 0
						fLick_trial_num = fLick_trial_num(2:end);
						idx_event = idx_event(2:end);
					end
					sObj.GLM.exclusionsTaken = true;
					exclIdx = find(ismember(fLick_trial_num, exclusionsFile));
					fLick_trial_num(exclIdx) = [];
	                idx_event(exclIdx) = [];
				
					firstLick_s = sObj.GLM.lick_s(idx_event);
					sObj.GLM.pos.lampOff = sObj.getXPositionsWRTgfit(sObj.GLM.lampOff_s);
					sObj.GLM.pos.cue = sObj.getXPositionsWRTgfit(sObj.GLM.cue_s);
					sObj.GLM.pos.fLick = round(1000*firstLick_s*sObj.Plot.samples_per_ms)+1;
					sObj.GLM.firstLick_s = firstLick_s;
					sObj.GLM.fLick_trial_num = fLick_trial_num;
				end
				sObj.GLM.isSingleSeshObj = true;
				% 
				%	Now, Z score the gfit data 
				% 
				if useZScore
					sObj.GLM.Z = obj.zScoreVector(sObj.GLM.gfit);
					Z = sObj.GLM.Z;
				else
					Z = sObj.GLM.gfit;
				end
				% 
				% 	Now, execute binning...
				% 
				if strcmpi(stimMode, 'stim')
					obj.updateLog('		Binning for Stim trials')
					if ~isfield(sObj.GLM, 'stimTrials')
						sObj.GLM.stimTrials = [];
                    end
                    % correct sampling rate...
                    sObj.correctSamplingRate();
					[sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad, sObj.GLM.stimTrials);
				elseif strcmpi(stimMode, 'noStim')
					obj.updateLog('		Binning for noStim trials')
					if ~isfield(sObj.GLM, 'noStimTrials')
						sObj.GLM.noStimTrials = 1:numel(sObj.GLM.cue_s);
                    end
                    % correct sampling rate...
                    sObj.correctSamplingRate();
					[sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad, sObj.GLM.noStimTrials);
				else
					obj.updateLog('		Stim mode is OFF')
                    % correct sampling rate...
                    sObj.correctSamplingRate();
					[sNc, sNl] = sObj.getBinnedTimeseries(Z, Mode, nbins, timePad);
				end
				% 
				% 	Now update the main obj's ts:
				% 
				if iset == 1
					% 
					% 	Initialize the ts structure. We won't bother filling the others, since this won't be used to GLM yet and the ts binning fxs work better
					% 
					for ibin = 1:nbins
					    obj.BinnedData.CTA{1,ibin} = nan(size(sObj.ts.BinnedData.CTA{1,ibin}));
					    obj.BinnedData.LTA{1,ibin} = nan(size(sObj.ts.BinnedData.LTA{1,ibin}));
					    obj.ts.BinnedData.CTA{1,ibin} = nan(size(sObj.ts.BinnedData.CTA{1,ibin}));
					    obj.ts.BinnedData.LTA{1,ibin} = nan(size(sObj.ts.BinnedData.LTA{1,ibin}));
					    obj.ts.BinParams.Legend_s = sObj.ts.BinParams.Legend_s;
                        obj.ts.BinParams.s = sObj.ts.BinParams.s;
                        obj.ts.BinParams.binEdges_CLTA = sObj.ts.BinParams.binEdges_CLTA;
                        obj.ts.BinParams.trials_in_each_bin{ibin} = 0;
					    obj.ts.BinParams.trials_in_each_bin{ibin} = numel(sObj.ts.BinParams.trials_in_each_bin{ibin});
                        obj.ts.BinParams.nbins_CLTA = sObj.ts.BinParams.nbins_CLTA;
                        obj.Plot.samples_per_ms = sObj.Plot.samples_per_ms;
                        obj.Plot.wrtCTAArray = sObj.Plot.wrtCTAArray;
                        obj.Plot.wrtCue = sObj.Plot.wrtCue;
                        obj.Plot.CTA = sObj.Plot.CTA;
                        obj.Plot.LTA = sObj.Plot.LTA;
                        obj.Plot.smooth_kernel = sObj.Plot.smooth_kernel;
					    obj.ts.Plot = sObj.ts.Plot;
                        if ~isempty(sNc{ibin})
                            sNc_total{ibin} = sNc{ibin};
                            sNl_total{ibin} = sNl{ibin};
                        else
                            sNc_total{ibin} = nan(size(sNc_total{1}));
                            sNl_total{ibin} = nan(size(sNl_total{1}));
                        end
					end				
				end
	    		% 
	    		% 	Updae our numbers...
	    		% 
                if ~isfield(sObj.iv.num_trials_category, 'num_no_ex_trials')
                    sObj.iv.num_trials_category.num_no_ex_trials = sObj.iv.num_trials_category.num_trials_category.num_no_ex_trials;
                end
                obj.iv.num_trials = obj.iv.num_trials + sObj.iv.num_trials;
	    		obj.iv.num_trials_category.num_no_ex_trials = obj.iv.num_trials_category.num_no_ex_trials + sObj.iv.num_trials_category.num_no_ex_trials;
	    		obj.iv.num_trials_category.num_no_rxn_or_ex_trials = obj.iv.num_trials_category.num_no_rxn_or_ex_trials + sObj.iv.num_trials_category.num_no_rxn_or_ex_trials;
	    		obj.iv.num_trials_category.num_rxn_not_ex_trials = obj.iv.num_trials_category.num_rxn_not_ex_trials + sObj.iv.num_trials_category.num_rxn_not_ex_trials;
	    		obj.iv.num_trials_category.num_early_not_ex_trials = obj.iv.num_trials_category.num_early_not_ex_trials + sObj.iv.num_trials_category.num_early_not_ex_trials;
	    		obj.iv.num_trials_category.num_rew_not_ex_trials = obj.iv.num_trials_category.num_rew_not_ex_trials + sObj.iv.num_trials_category.num_rew_not_ex_trials;
	    		obj.iv.num_trials_category.num_ITI_not_ex_trials = obj.iv.num_trials_category.num_ITI_not_ex_trials + sObj.iv.num_trials_category.num_ITI_not_ex_trials;
	    		obj.iv.num_trials_category.note = 'numbers accurate if no additional excl taken in v3x';
				%
				%   Running mean of all the datasets for each bins
				%
				if iset == 1
					% 	To be used in running ave (see below): Initialize our counters for the number of trials in the obj
					s1c = cellfun(@(x) x./nan, sNc, 'UniformOutput', 0);
					s1l = cellfun(@(x) x./nan, sNl, 'UniformOutput', 0);
					for ibin = 1:numel(s1c)
						if isempty(s1c{ibin})
							s1c{ibin} = s1c{1};
						end
						if isempty(s1l{ibin})
							s1l{ibin} = s1l{1};
						end
					end
				end
			    for ibin = 1:nbins
			    	if iset ~= 1
                        if ~isempty(sNc{ibin})
    			    		sNc_total{ibin} = nansum([sNc{ibin}; sNc_total{ibin}], 1);
                            sNl_total{ibin} = nansum([sNl{ibin}; sNl_total{ibin}], 1);

                            sNc_total{ibin}(sNc_total{ibin} == 0) = nan;
                            sNl_total{ibin}(sNl_total{ibin} == 0) = nan;
                        end
					    obj.ts.BinParams.trials_in_each_bin{ibin} = obj.ts.BinParams.trials_in_each_bin{ibin} + numel(sObj.ts.BinParams.trials_in_each_bin{ibin});
		    		end
                    % 
		    		% 	Fix the legend
		    		% 
		    		npos = strsplit(obj.ts.BinParams.Legend_s.CLTA{ibin}, 'n='); 
		    		obj.ts.BinParams.Legend_s.CLTA{ibin} = [npos{1}, 'n=', num2str(obj.ts.BinParams.trials_in_each_bin{ibin})];
			    	% 
			    	% 	First, multiply each sObj bin by the number of samples so we can combine correctly
			    	% 
                    if divideByNTrialsPerBin && ~isempty(sNc{ibin}) && ~isempty(sNl{ibin})
      %                   nL(isnan(nL)) = 0;
						% nL = nL+1;
						% nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
						% nL(nL==0) = nan;


						% nanCposT = isnan(sNc_total{ibin});
						% sNc_total = 1;

						% nanCpos = isnan(sNc{ibin});
						% nanCpos = 1;
						% warning('The running ave isn''t working right! 6-20-19') --  RESOLVED 6-20-19
                        % nxt = [sObj.ts.BinnedData.CTA{1,ibin} .*sNc{ibin}]./sNc_total{ibin}; % keeps nan in place
                        % obj.ts.BinnedData.CTA{1,ibin} = nansum([obj.ts.BinnedData.CTA{1,ibin} .* ((sNc_total{ibin}-1)./sNc_total{ibin}); nxt]); % ignores the nans  

                        % nxt = [sObj.ts.BinnedData.LTA{1,ibin} .*sNl{ibin}]./sNl_total{ibin}; % keeps nan in place
                        % obj.ts.BinnedData.LTA{1,ibin} = nansum([obj.ts.BinnedData.LTA{1,ibin} .* ((sNl_total{ibin}-1)./sNl_total{ibin}); nxt]); % ignores the nans

                        % 
                        % 	Multirunning ave: must multiply each existing ave by its total components first, then divide by overall total
                        % 		eg:
                        % 			ave n1: nbar1 = sum(n1)/s1, where s1 is the number of samples in set n1
                        % 			ave n2: nbar2 = sum(n2)/s2, where s2 is the number of samples in set n2
                        % 			ave (n1, n2): [(s1 * nbar1) + (s2 * nbar2)]/(s1 + s2)
                        % 						= [N1 + N2]
                        % 
                        % 	n1 is the set of trials already in obj
                        % 	n2 is the set of trials to be added from sObj
                        % 
                        s1c{ibin} = s1c{ibin}; % defined in last iter as # of trials in obj
                        s2c = sNc{ibin};
                        assert([sum(sNc_total{ibin} == nansum([s1c{ibin}; s2c])) == numel(s1c{ibin})]); % debug
                        if ~isempty(sNc_total{ibin})
                            N1c = [obj.ts.BinnedData.CTA{1,ibin} .* s1c{ibin}]./sNc_total{ibin}; 
                            N2c = [sObj.ts.BinnedData.CTA{1,ibin} .* s2c]./sNc_total{ibin};
                            obj.ts.BinnedData.CTA{1,ibin} = nansum([N1c; N2c]);
                        else
                            obj.ts.BinnedData.CTA{1,ibin} = [];
                        end


                        s1l{ibin} = s1l{ibin}; % defined in last iter as # of trials in obj
                        s2l = sNl{ibin};
                        % assert([sNc_total{ibin} == s1l(ibin) + s2l]); % debug
                        N1l = [obj.ts.BinnedData.LTA{1,ibin} .* s1l{ibin}]./sNl_total{ibin}; 
                        N2l = [sObj.ts.BinnedData.LTA{1,ibin} .* s2l]./sNl_total{ibin};
                        obj.ts.BinnedData.LTA{1,ibin} = nansum([N1l; N2l]);

                        %  Update the number of trials in the obj:
                        s1c{ibin} = sNc_total{ibin}; 
                        s1l{ibin} = sNl_total{ibin}; 

                    elseif ~divideByNTrialsPerBin && ~isempty(sNc{ibin}) && ~isempty(sNl{ibin})
      					% 
      					% 	If we don't want to normalize to the number of trials included in the bin, we just want to running average
      					% 
      					error('Obsolete! 6-20-19')
                        nxt = sObj.ts.BinnedData.CTA{1,ibin}; % keeps nan in place
                        obj.ts.BinnedData.CTA{1,ibin} = nanmean([obj.ts.BinnedData.CTA{1,ibin}; nxt]); 

                        nxt = sObj.ts.BinnedData.LTA{1,ibin}; % keeps nan in place
                        obj.ts.BinnedData.LTA{1,ibin} = nanmean([obj.ts.BinnedData.LTA{1,ibin}; nxt]); % ignores the nans  
                    	
                    else
                        disp(['				This bin was empty: ' num2str(ibin)]);
                    end
			    end
				% 
				% 	Pull out Mouse Name and Session # for our record keeping
				% 
				obj.iv.datasetMap(iset).mouseName = sObj.iv.mousename_;
                if ~isfield(sObj.iv, 'daynum_')
                    a = strsplit(sObj.iv.files,'day');
                    b = strsplit(a{2},'_');
                    sObj.iv.daynum_ = b{1};
                end
				obj.iv.datasetMap(iset).dayNum = sObj.iv.daynum_;
                %
                %   Combine existing exc with exc file
                exclusionsFile = {exclusionsFile, sObj.iv.exclusions_struct.Excluded_Trials};
                %
				obj.iv.datasetMap(iset).exclusions = exclusionsFile;
				obj.iv.datasetMap(iset).path = [folderPaths{iset} '\' folderNames{iset}];	
                obj.iv.setStyle = 'v3x Combined Datasets';
				% 
				% 	Remove s7s before start next obj and reset everything
				% 
				if exist('s7s')
					clear s7s;
				end
				% 
				% 	Check for sampling rate warning flag
				% 
				if isfield(sObj.iv, 'FLAG') && sObj.iv.FLAG
					obj.updateLog(' 	*** DATASET FLAGGED FOR UNEXPECTED SAMPLING RATE *** \n')
					msgbox(['Dataset ' folderNames{iset} ' (' num2str(iset) '/' num2str(numel(folderNames)) ') flagged for unexpected sampling rate: ' num2str(sObj.Plot.samples_per_ms)])
				end
				clear sObj
				cd(hostFolder)
				% 
				% 	If SaveMode is on, we will immediately save to the directory with timestamp
				% 
				if obj.SaveMode
					warning('No longer saving intermediate objs because not useful.')
					% timestamp_now = datestr(now,'mm_dd_yy__HH_MM_AM');
					% savefilename = ['Intermediate_statObj_Mode' obj.Mode '_' num2str(obj.BinParams.ogBins) 'bins_stimMode' stimMode, '_' timestamp_now];
					% save([savefilename, '.mat'], 'obj', '-v7.3');
					% obj.updateLog(['	Saved INTERMEDIATE object to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat (' datestr(now,'HH:MM AM') ') \n']);
				end
			end
			obj.updateLog('======================================== \n')
			% 
			% 	Save the final object
			% 
			timestamp_now = datestr(now,'mm_dd_yy__HH_MM_AM');
			savefilename = cell2mat(['V3xFinal_' obj.iv.signalname '_statObj_Mode' obj.Mode '_' num2str(numel(obj.BinnedData.CTA)) 'bins_stimMode' stimMode, '_' timestamp_now]);
			save([savefilename, '.mat'], 'obj', '-v7.3');
			obj.updateLog(['Saved initiated object to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat (' datestr(now,'HH:MM AM') ') \n']);
			% 
			obj.updateLog(['Stat object generated and ready to use. ' datestr(now,'HH:MM AM') ') \n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n']);
			% 
		end

		function initStimNPhotObj(obj, Mode, nbins, gfitStyle, timePad, stimMode)
			% 
			% 	stimMode options: 'stim', 'noStim' --> bins the trials that are either stim'd on or not
			% 						'off' --> bins all trials, regardless of stim state
			% 
			% 	ignoreStim: refers to if we want to chop out stimulation times from our data so as to avoid artifacts
			% 				As of 9/18/19, default will be to not chop when 'off', thus ignoreStim = 0
			% 					and to chop when stimulation is on, hence ignoreStim = 1 for 'stim', 'on', or 'noStim'
			% 
			if nargin < 6 || strcmpi(stimMode, 'off')
				ignoreStim = 0;
			elseif strcmpi(stimMode, 'stim') || strcmpi(stimMode, 'on') || strcmpi(stimMode, 'noStim')
				warning('This got messed up for stimNphot objs when trying to do the ChR2 mode... need to fix this later...')
				ignoreStim = 1;
			end
			% 
			% 	Store this now in the ChR2 field
			% 
			obj.ChR2.ignoreStim = ignoreStim;
			% 
			% 	Handle non-standard trial parameters
			% 
			if ~isfield(obj.iv, 'BingoMODE')
				obj.iv.BingoMODE = false; % note there's a second place you need to set this to true for 7.5s target
			end
			autorun = 1;	
			if ~autorun
				mydlg = msgbox(sprintf('StimNPhot Processor Version 3.x Instructions: \n\n 1. Select the CED file and save file. Go ahead and take exclusions. \n\n 2. Program bins both the X signal and the phot signal of your choice, irrespective of stim/unstim. These are the default binnings \n\n 3. To flexibly bin only stim, unstim, or desired trial Idxs, use obj.getBinnedTimeseries(obj.GLM.gfit, ''outcome'', 6, 15000, obj.GLM.stimIdx or Idx of your choice); Things get plotted as you like, use the ts binned data for plots! \n\n\n '));
				uiwait(mydlg);
			end
			obj.SaveMode = true; % in this case, will save intermediate objects in case of crash in the middle of processing...
			% 
			% 	Now generate the log
			% 
			obj.Log = {};
			obj.generateLog();
			obj.updateLog(['Created Log. (' datestr(now,'HH:MM AM') ') \n']);
			% 
			% 	We will start by initializing all the params for the object, as we usually do. We will constrain all the loaded files to match these params
			% 
			%	Certain params will be specified at outset, here: 
			% 
			disp('Using default trial parameters. If trial length or times is different from standard, update here...')
			obj.updateLog('Using default trial parameters. \n');
			obj.iv.setStyle = 'v3x-single session';
			obj.iv.date = datestr(now);			warning('Only use stimNphot for 0ms rxn window operant data... preprocess with roadmap for now if not')
			obj.iv.exptype_ = 'op';
			obj.iv.rxnwin_ = 0;
			obj.iv.total_time_ = 17000;
			obj.iv.num_trials = 0;
			obj.iv.num_trials_category.num_no_ex_trials = 0;
			obj.iv.num_trials_category.num_no_rxn_or_ex_trials = 0;
			obj.iv.num_trials_category.num_rxn_not_ex_trials = 0;
			obj.iv.num_trials_category.num_early_not_ex_trials = 0;
			obj.iv.num_trials_category.num_rew_not_ex_trials = 0;
			obj.iv.num_trials_category.num_ITI_not_ex_trials = 0;
			% 
		 	%	1. Request user to select the raw datafile OR select automatically
		 	% 
		 	if ~autorun
				[FileName,PathName,FilterIndex]= uigetfile('./*.mat', 'Select file to analyze...');
				if FileName
	                obj.iv.analysis_file = [PathName, FileName];
					load(obj.iv.analysis_file);
				else
					error('Using current spike2 file in workspace!')
				end
				folder_name = uigetdir('','Select folder to save to...');
				cd(folder_name);
				% 
				% 	First, check and see if the signal name is in the title of the folder:
				% 
				obj.iv.signalname = '';
				fn = {'SNc', 'DLS', 'VTA', 'DLSright', 'DLSleftD', 'SNcred', 'VTAred', 'DLSred', 'EMG', 'X', 'Y', 'Z', 'CamO', 'ChR2', 'SNcnovir', 'VTAnovir', 'SNcgreen', 'VTAgreen', 'DLSgreen', 'NAc', 'NAcred'};			
				idxrg_phot = [1:5, 20];
				idxrg_ctrlphit = [6:8, 15, 16, 17, 18, 19, 21];
				idxrg_move = [9:13];
				idxrg_stim = [14];
				folderSignal=strsplit(folder_name,{'\','/'});
	            folderSignal=strsplit(folderSignal{end},'_');
				disp([' DEBUG======: folderSignal: ' folderSignal{end}])
				if sum(strcmp(folderSignal{3}, fn)) == 1
					indx = find(strcmp(folderSignal{3}, fn));
					disp(['		~~~ Detected signal name ' fn{indx} ' from folder!'])
				elseif numel(folderSignal) > 1 && sum(strcmp(folderSignal{2}, fn)) == 1
					indx = find(strcmp(folderSignal{2}, fn));
					disp(['		~~~ Detected signal name ' fn{indx} ' from folder!'])
				else
					[indx,~] = listdlg('PromptString','Select data type to include...',...
				                           'ListString',fn);
				end

				if isempty(indx)
					disp('cancelled.')
					return	
				else
					obj.iv.signalname = fn(indx);
					if ismember(indx, idxrg_phot) || ismember(indx, idxrg_ctrlphit)
						obj.iv.signaltype_ = 'photometry';
					elseif ismember(indx, idxrg_move)
						if indx == idxrg_move(1)
							obj.iv.signaltype_ = 'EMG';
							% gfitStyle = {'Abs-hipass-EMG', []};
							gfitStyle = {'EMG', []};
						elseif ismember(indx, idxrg_move(2:4))
							obj.iv.signaltype_ = 'accelerometer';
							gfitStyle = {'Abs-X', []};
							% gfitStyle = {'Abs-Xderivative', []};
						elseif indx == idxrg_move(5)
							obj.iv.signaltype_ = 'camera';
							error('not implemented')
							gfitStyle = {'Abs-CamOderivative', []};
						end
					elseif ismember(indx, idxrg_stim)
						obj.iv.signaltype_ = 'optogenetics';
						gfitStyle = {'ChR2', []};
					end		
					obj.iv.ctrl_signalname = 'X';
					obj.iv.ctrl_signaltype_ = {'accelerometer'};			
				end
				% 
				% 	Get session params:
				% 
				prompt = {'Day # prefix:','CED filename_ (don''t include *_lick, etc):', 'Header number:', 'Exclusion Criteria Version', 'Animal Name', 'Excluded Trials', 'Ignore stim?'};
				dlg_title = 'Inputs';
				num_lines = 1;
				parsing = strsplit(FileName, '_');
				mname = parsing{1};
				parsing = strsplit(parsing{end}, 'y');
				nday = strsplit(parsing{end}, '.');
				nday = nday{1};

				defaultans = {nday,FileName(1:end-4),'3', 'op', mname, 'g:', '1'};
				answer_ = inputdlg(prompt,dlg_title,num_lines,defaultans);
				obj.iv.daynum_ = answer_{1};
				obj.iv.filename_ = answer_{2};
				obj.iv.headernum_ = answer_{3};
				obj.iv.exclusion_criteria_version_ = answer_{4};
				obj.iv.mousename_ = answer_{5};
				obj.iv.excludedtrials_ = answer_{6};
	            ignoreStim = str2num(answer_{7});
				Excluded_Trials = [];
				% 
				% 	Set up pointers to key vars in the CED file:
				% 
				eval(['obj.GLM.cue_s = ' obj.iv.filename_ '_Start_Cu.times;']);
				eval(['obj.GLM.lampOff_s = ' obj.iv.filename_ '_Lamp_OFF.times;']);
				eval(['obj.GLM.lick_s = ' obj.iv.filename_ '_Lick.times;']);
				if ~strcmp(obj.iv.signaltype_, 'camera') && ~strcmp(obj.iv.signaltype_, 'optogenetics')
                    eval(['obj.GLM.gtimes = ' obj.iv.filename_ '_' obj.iv.signalname{1,1} '.times;']);
					eval(['obj.GLM.rawF = ' obj.iv.filename_ '_' obj.iv.signalname{1,1} '.values;']);
                elseif strcmp(obj.iv.signaltype_, 'optogenetics')
                	eval(['obj.GLM.ChR2 = ' obj.iv.filename_ '_' obj.iv.signalname{1,1} '.times;']);
					eval(['obj.GLM.ChR2times = ' obj.iv.filename_ '_' obj.iv.signalname{1,1} '.values;']);
                else
                	fieldIdx = contains(signals, 'CamO');
                    eval(cell2mat(['obj.GLM.CamOtimes = ' obj.iv.filename_ '_CamO.times;']));
                    obj.GLM.gtimes = obj.GLM.CamOtimes;
					fieldIdx = contains(signals, 'IRtrig');
                    eval(cell2mat(['obj.GLM.IRtrig = ' obj.iv.filename_ '_IRtrig.times;']));
                end
				
				noCtrlSig = false;
				
				if strcmpi(obj.iv.signaltype_, 'optogenetics')
					obj.GLM.note{1} = 'Optogenetics Object Notes';
					obj.GLM.note{end+1} = 'EMG is rectified. Camera signals are standard Abs-CamOderivative. X is Abs-Xderivative.';
					% 
					% 	This is a primarily optogenetics object, so we will acquire everything
					%
					try
						eval(['obj.GLM.X = ' obj.iv.filename_ '_X.values;']);
						eval(['obj.GLM.Xtimes = ' obj.iv.filename_ '_X.times;']);
						obj.GLM.X = [0;abs(obj.GLM.X(2:end)-obj.GLM.X(1:end-1))];
					catch
						obj.GLM.note{end+1} = 'No X for this set.';
					end
					try
						eval(['obj.GLM.EMG = abs(' obj.iv.filename_ '_EMG.values);']);
						eval(['obj.GLM.EMGtimes = ' obj.iv.filename_ '_EMG.times;']);
					catch
						obj.GLM.note{end+1} = 'No EMG for this set.';
					end
					try
						eval(cell2mat(['obj.GLM.CamOtimes = ' obj.iv.filename_ '_CamO.times;']));
	                    eval(cell2mat(['obj.GLM.IRtrig = ' obj.iv.filename_ '_IRtrig.times;']));
						[fname, pname] = uigetfile('.mat', 'Select AbsCamODerivative gfit file');
						if ~fname
		                    obj.GLM.AbsCamODerivative = abs(obj.gfitCamera(obj.GLM.CamOtimes, obj.GLM.IRtrig));
	                	else
	                	    load([pname, '\', fname]);
	                	    gfitderivative = gfitderivative.gfitderivative;
	                	    obj.GLM.AbsCamODerivative = abs(gfitderivative);
                	    end  
	                    % 
	                    %	Append nans to the front before the camera trigger 
	                    % 
	                    nanpad = nan(1, find(obj.GLM.CamOtimes > obj.GLM.IRtrig, 1, 'first')-1);
	                    obj.GLM.AbsCamODerivative = [nanpad, obj.GLM.AbsCamODerivative];
	                    %
	                    %   Chop the ChR2 times
	                    %
	                    if ignoreStim
	                        error('RBF')
	                        obj.GLM.AbsCamODerivative(obj.GLM.pos.ChR2) = nan;
	                        obj.GLM.note{end+1} = 'AbsCamODerivative has nans during stim light to ignore flashing from stimulation in the signal';
	                    end
                    catch
						obj.GLM.note{end+1} = 'No parsible video for this set.';
					end
				else
					% gather control signals for NON-optogenetics objects
					try
						eval(['obj.GLM.X = ' obj.iv.filename_ '_X.values;']);
						eval(['obj.GLM.Xtimes = ' obj.iv.filename_ '_X.times;']);
					catch
						disp('No X-signal. Trying EMG')
						try
							eval(['obj.GLM.EMG = ' obj.iv.filename_ '_EMG.values;']);
							eval(['obj.GLM.EMGtimes = ' obj.iv.filename_ '_EMG.times;']);
						catch
							disp('No control signals. Moving on.')
							noCtrlSig = 1;
						end
					end
				end
				
	            if ignoreStim && strcmpi(obj.iv.signaltype_, 'optogenetics')
	                obj.GLM.ChR2_s = obj.GLM.ChR2times;
	                obj.GLM.ChR2values = obj.GLM.ChR2;
                elseif ignoreStim && ~strcmpi(obj.iv.signaltype_, 'optogenetics')
                	eval(['obj.GLM.ChR2_s = s7s.' obj.iv.filename_(1:end-1) '_ChR2.times;']);
	                eval(['obj.GLM.ChR2values = s7s.' obj.iv.filename_(1:end-1) '_ChR2.values;']);
	            end
			else
				dirFiles = dir;
				folder_name = pwd;
				% 
				% 	First, check and see if the signal name is in the title of the folder:
				% 
				folderSignal=strsplit(folder_name,{'\', '/'});
	            folderSignal=strsplit(folderSignal{end},'_');
	            fn = {'SNc', 'DLS', 'VTA', 'DLSright', 'DLSleftD', 'SNcred', 'VTAred', 'DLSred', 'EMG', 'X', 'Y', 'Z', 'CamO', 'ChR2', 'SNcnovir', 'VTAnovir', 'SNcgreen', 'VTAgreen', 'DLSgreen', 'NAc', 'NAcred'};			
				idxrg_phot = [1:5, 20];
				idxrg_ctrlphit = [6:8, 15, 16, 17, 18, 19, 21];
				idxrg_move = [9:13];
				idxrg_stim = [14];
				disp([' DEBUG======: folderSignal: ' folderSignal{end}])
				if sum(contains(folderSignal, fn))%sum(strcmp(folderSignal{3}, fn)) == 1
					indx = find(contains(folderSignal, fn));%find(strcmp(folderSignal{3}, fn));
                    indx = find(strcmp(folderSignal{indx}, fn));
					disp(['		~~~ Detected signal name ' fn{indx} ' from folder!'])
% 				elseif numel(folderSignal) > 1 && sum(strcmp(folderSignal{2}, fn)) == 1
% 					indx = find(strcmp(folderSignal{2}, fn));
% 					disp(['		~~~ Detected signal name ' fn{indx} ' from folder!'])
				else
					error('A problem! Or a blessing?')
				end

				if isempty(indx)
					disp('cancelled.')
					return	
				else
					obj.iv.signalname = fn(indx);
					if ismember(indx, idxrg_phot) || ismember(indx, idxrg_ctrlphit)
						obj.iv.signaltype_ = 'photometry';
					elseif ismember(indx, idxrg_move)
						if indx == idxrg_move(1)
							obj.iv.signaltype_ = 'EMG';
							% gfitStyle = {'Abs-hipass-EMG', []};
							gfitStyle = {'EMG', []};
						elseif ismember(indx, idxrg_move(2:4))
							obj.iv.signaltype_ = 'accelerometer';
							gfitStyle = {'Abs-X', []};
							% gfitStyle = {'Abs-Xderivative', []};
						elseif indx == idxrg_move(5)
							obj.iv.signaltype_ = 'camera';
							warning('RBF')
							gfitStyle = {'Abs-CamOderivative', []};
                        end
                    elseif indx == idxrg_stim
                        obj.iv.signaltype_ = 'optogenetics';
                        gfitStyle = {'ChR2', []};
                    end
					obj.iv.ctrl_signalname = 'X';
					obj.iv.ctrl_signaltype_ = {'accelerometer'};			
				end
				% 
				% 	Get session params:
				% 
				folderSignal=strsplit(folder_name,{'\', '/'});
	            folderSignal=strsplit(folderSignal{end},'_');
	            if numel(folderSignal) == 3
					obj.iv.daynum_ = folderSignal{end};
				elseif numel(folderSignal) == 4
					obj.iv.daynum_ = [folderSignal{end-1} '_' folderSignal{end}];
				end
				% 
				% 	First, find the CED file:
				% 
				s7spos = find(contains({dirFiles(3:end).name}, '.mat') &  ~contains({dirFiles(3:end).name},'GLM') & ~contains({dirFiles(3:end).name},'gfit') & ~contains({dirFiles(3:end).name},'si_LTA_ITI_')& ~contains({dirFiles(3:end).name},'excl') & ~contains({dirFiles(3:end).name},'roadmap') & ~contains({dirFiles(3:end).name},'Obj') & ~contains({dirFiles(3:end).name},'processed') &  ~contains({dirFiles(3:end).name},'obj') &  ~contains({dirFiles(3:end).name},'Licks_and') & ~contains({dirFiles(3:end).name},'v3x')) + 2;
				s7s = load([dirFiles(s7spos).folder, '\', dirFiles(s7spos).name]);
				obj.updateLog('		Detected CEDpos in folder and loaded')
				signals = fieldnames(s7s);
				% 
				% 	Once in the spike 2 file, extract anything relevant for actual signals...
				% 
				fieldIdx = contains(signals, 'Start_Cu');
				eval(cell2mat(['obj.GLM.cue_s = s7s.' signals(fieldIdx) '.times;']));
				fieldIdx = contains(signals, 'Lick');
				eval(cell2mat(['obj.GLM.lick_s = s7s.' signals(fieldIdx) '.times;']));
				fieldIdx = contains(signals, 'Lamp_OFF');
				eval(cell2mat(['obj.GLM.lampOff_s = s7s.' signals(fieldIdx) '.times;']));
				fieldIdx = contains(signals, obj.iv.signalname);
				if sum(fieldIdx) > 1
                    fff = find(fieldIdx);
					for ifield = 1:numel(fff)
                        iifield = fff(ifield);
						if signals{iifield,1}(end) ~= obj.iv.signalname{end}(end)
							fieldIdx(iifield) = 0;
						end
					end
				end
                if ~strcmp(obj.iv.signaltype_, 'camera') && ~strcmp(obj.iv.signaltype_, 'optogenetics')
                    eval(cell2mat(['obj.GLM.rawF = s7s.' signals(fieldIdx) '.values;']));
                    eval(cell2mat(['obj.GLM.gtimes = s7s.' signals(fieldIdx) '.times;']));
                elseif strcmp(obj.iv.signaltype_, 'optogenetics')
                	eval(cell2mat(['obj.GLM.ChR2 = s7s.' signals(fieldIdx) '.values;']));
                    eval(cell2mat(['obj.GLM.ChR2times = s7s.' signals(fieldIdx) '.times;']));
                else
                	fieldIdx = contains(signals, 'CamO');
                    eval(cell2mat(['obj.GLM.CamOtimes = s7s.' signals(fieldIdx) '.times;']));
                    obj.GLM.gtimes = obj.GLM.CamOtimes;
					fieldIdx = contains(signals, 'IRtrig');
                    eval(cell2mat(['obj.GLM.IRtrig = s7s.' signals(fieldIdx) '.times;']));
                end
				obj.iv.filename_ = dirFiles(s7spos).name;
				obj.iv.filename_ = obj.iv.filename_(1:end-3);
				obj.iv.headernum_ = '3';
				obj.iv.exclusion_criteria_version_ = '1';
				obj.iv.mousename_ = folderSignal{1};
				
				Excluded_Trials = [];					
				% 
				% 	Load Exclusions Variable -- only need this to add more exclusions than you originally used
				% 
				excPos = find(contains({dirFiles.name},'exclusions'));
				if ~isempty(excPos)
					obj.iv.excludedtrials_ = fileread([dirFiles(excPos).folder, '\', dirFiles(excPos).name]);
				else
					error('Need to put in exclusion file for autoloader!')
				end
				noCtrlSig = false;


				if strcmpi(obj.iv.signaltype_, 'optogenetics')
					ignoreStim = true;
					obj.GLM.note{1,1} = 'Optogenetics Object Notes';
					obj.GLM.note{end+1,1} = 'EMG is rectified. Camera signals are standard Abs-CamOderivative. X is Abs-Xderivative.';
					% 
					% 	This is a primarily optogenetics object, so we will acquire everything
					%
					try
						fieldIdx = find(contains(signals, 'X'));
						eval(['obj.GLM.X = s7s.' signals{fieldIdx} '.values;']);
						eval(['obj.GLM.Xtimes = s7s.' signals{fieldIdx} '.times;']);
						obj.GLM.X = [0;abs(obj.GLM.X(2:end)-obj.GLM.X(1:end-1))];
					catch
						obj.GLM.note{end+1,1} = 'No X for this set.';
					end
					try
						fieldIdx = find(contains(signals, 'EMG'));
						eval(['obj.GLM.EMG = abs(s7s.' signals{fieldIdx} '.values);']);
						eval(['obj.GLM.EMGtimes = s7s.' signals{fieldIdx} '.times;']);
					catch
						obj.GLM.note{end+1,1} = 'No EMG for this set.';
					end
					try
						warning('RBF')
						fieldIdx = find(contains(signals, 'CamO'));
	                    eval(['obj.GLM.CamOtimes = s7s.' signals{fieldIdx} '.times;']);
	                    fieldIdx = find(contains(signals, 'IRtrig'));
	                    eval(['obj.GLM.IRtrig = s7s.' signals{fieldIdx} '.times;']);
						
						gfitderivpos = find(contains({dirFiles(3:end).name}, '.mat') & contains({dirFiles(3:end).name},'AbsCamODerivative') & contains({dirFiles(3:end).name},'v3x9')) + 2;
						if ~gfitderivpos		                
		                    obj.GLM.AbsCamODerivative = abs(obj.gfitCamera(obj.GLM.CamOtimes, obj.GLM.IRtrig));
	                	else
	                	    gfitderivative = load([dirFiles(gfitderivpos).folder, '\', dirFiles(gfitderivpos).name]);
	                	    gfitderivative = gfitderivative.gfitderivative;
							obj.updateLog('		Detected AbsCamODerivative in folder and loaded')
	                	    obj.GLM.AbsCamODerivative = abs(gfitderivative);
                	    end  
						% 
	                    %	Append nans to the front before the camera trigger 
	                    % 
	                    nanpad = nan(1, find(obj.GLM.CamOtimes > obj.GLM.IRtrig, 1, 'first')-1);
	                    obj.GLM.AbsCamODerivative = [nanpad, obj.GLM.AbsCamODerivative];
	                    %
	                    %   Chop the ChR2 times
	                    %
	                    if ignoreStim
	                        error('RBF')
	                        obj.GLM.AbsCamODerivative(obj.GLM.pos.ChR2) = nan;
	                        obj.GLM.note{end+1,1} = 'AbsCamODerivative has nans during stim light to ignore flashing from stimulation in the signal';
	                    end
                    catch
						obj.GLM.note{end+1,1} = 'No parsible video for this set.';
					end
				else
					% gather control signals for NON-optogenetics objects
					try
						eval(['obj.GLM.X = s7s.' obj.iv.filename_(1:end-1) '_X.values;']);
						eval(['obj.GLM.Xtimes = s7s.' obj.iv.filename_(1:end-1)  '_X.times;']);
					catch
						disp('No X-signal. Trying EMG')
						try
							eval(['obj.GLM.EMG = s7s.' obj.iv.filename_(1:end-1)  '_EMG.values;']);
							eval(['obj.GLM.EMGtimes = s7s.' obj.iv.filename_(1:end-1)  '_EMG.times;']);
						catch
							try
								disp('No EMG-signal. Trying alternate X variable')
								fieldIdx = contains(signals, 'X');
								eval(cell2mat(['obj.GLM.X = s7s.' signals(fieldIdx) '.values;']));
								eval(cell2mat(['obj.GLM.Xtimes = s7s.' signals(fieldIdx) '.times;']));
							catch
								try 
									disp('No X-signal. Trying alternate EMG variable')
									fieldIdx = contains(signals, 'EMG');
									eval(cell2mat(['obj.GLM.EMG = s7s.' signals(fieldIdx) '.values;']));
									eval(cell2mat(['obj.GLM.EMGtimes = s7s.' signals(fieldIdx) '.times;']));

								catch
									disp('No control signals. Moving on.')
									noCtrlSig = 1;
								end
							end
						end
					end
				end
				
	            if ignoreStim && strcmpi(obj.iv.signaltype_, 'optogenetics')
	                obj.GLM.ChR2_s = obj.GLM.ChR2times;
	                obj.GLM.ChR2values = obj.GLM.ChR2;
                elseif ignoreStim && ~strcmpi(obj.iv.signaltype_, 'optogenetics')
                	eval(['obj.GLM.ChR2_s = s7s.' obj.iv.filename_(1:end-1) '_ChR2.times;']);
	                eval(['obj.GLM.ChR2values = s7s.' obj.iv.filename_(1:end-1) '_ChR2.values;']);
	            end
			end
			
			
			
			obj.iv.num_trials = numel(obj.GLM.cue_s);
			% 
			%  Parse Exclusions
			% 
			ichar = 1;
            while ichar <= length(obj.iv.excludedtrials_)
                if strcmp(obj.iv.excludedtrials_(ichar),' ')
                    ichar = ichar + 1;
                elseif ismember(obj.iv.excludedtrials_(ichar), '0123456789')
                    jchar = ichar;
                    next_number = '';
                    while jchar <= length(obj.iv.excludedtrials_) && ismember(obj.iv.excludedtrials_(jchar), '0123456789')% get the single numbers eg 495
                        next_number(end+1) = obj.iv.excludedtrials_(jchar);
                        jchar = jchar + 1;
                    end
                    next_number = str2double(next_number);
                    if next_number <= obj.iv.num_trials % otherwise ignore bc is not in range
                        Excluded_Trials(end + 1) = next_number;
                    end
                    ichar = jchar;
                elseif strcmp(obj.iv.excludedtrials_(ichar),'-')
                    while ichar <= length(obj.iv.excludedtrials_) && ~ismember(obj.iv.excludedtrials_(ichar), '0123456789')
                        ichar = ichar + 1;
                    end
                    jchar = ichar;
                    next_number = '';
                    while jchar <= length(obj.iv.excludedtrials_) && ismember(obj.iv.excludedtrials_(jchar), '0123456789')% get the single numbers eg 495
                        next_number(end+1) = obj.iv.excludedtrials_(jchar);
                        jchar = jchar + 1;
                    end
                    next_number = str2double(next_number);
                    if next_number <= obj.iv.num_trials && ~isempty(Excluded_Trials)
                        trials_to_append = (Excluded_Trials(end)+1:next_number);
                        Excluded_Trials = horzcat(Excluded_Trials,trials_to_append);	
                    elseif ~isempty(Excluded_Trials)
                        trials_to_append = (Excluded_Trials(end)+1:obj.iv.num_trials);
                        Excluded_Trials = horzcat(Excluded_Trials,trials_to_append);
                    else
                        warning('Should only reach this line if there''s a dash between two non-numbers')
                    end
                    ichar = ichar;
                else
                    disp(['parse error: only use numbers, spaces and dashes. you entered: ', obj.iv.excludedtrials_(ichar)])
                    ichar = ichar + 1;
                end
            end
            obj.iv.exclusions_struct.Excluded_Trials = Excluded_Trials;
			% 
			% 	Collect plot references from init_variables
			% 
            obj.getPlot([], true);
            if ~isfield(obj.iv, 'BingoMODE') || ~obj.iv.BingoMODE
	            obj.Plot.wrtCue.Events.ms.rxn_time_ms = 500;
	            obj.Plot.wrtCue.Events.ms.buffer_ms = 200;
	            % obj.Plot.wrtCue.Events.ms.op_rew_open_ms = 3333;
	            % obj.Plot.wrtCue.Events.ms.ITI_time_ms = 7000;
	            % obj.Plot.wrtCue.Events.ms.total_time_ms = 17000;
	            
	            obj.Plot.wrtCue.Events.s.rxn_time_ms = 0.5;
	            obj.Plot.wrtCue.Events.s.buffer_ms = 0.2;
	            % obj.Plot.wrtCue.Events.s.op_rew_open_ms = 3.333;
	            % obj.Plot.wrtCue.Events.s.ITI_time_ms = 7;
	            % obj.Plot.wrtCue.Events.s.total_time_ms = 17;
            else
	            warning('In BingoMODE t7.5')
                obj.iv.total_time_ = 20000;
	            obj.Plot.wrtCue.Events.ms.op_rew_open_ms = 4950;
	            obj.Plot.wrtCue.Events.ms.ITI_time_ms = 10000;
	            obj.Plot.wrtCue.Events.ms.total_time_ms = 20000;
				obj.Plot.wrtCue.Events.s.op_rew_open_ms = 4.950;
	            obj.Plot.wrtCue.Events.s.ITI_time_ms = 10;
	            obj.Plot.wrtCue.Events.s.total_time_ms = 20;
			end
			% 
			%	Find ChR2 up times by 2V threshold 
			% 
            if ignoreStim
                obj.GLM.pos.ChR2 = find(obj.GLM.ChR2values > 2);
                uptimesright = obj.GLM.pos.ChR2 + 2;
                uptimesleft = obj.GLM.pos.ChR2 - 2;
                obj.GLM.pos.ChR2 = unique(horzcat(obj.GLM.pos.ChR2, uptimesright, uptimesleft));
            else
                obj.GLM.pos.ChR2 = [];
            end
			% 
			%	Preprocess X data 
			%
			if ~noCtrlSig && isfield(obj.GLM, 'X')
				obj.GLM.gX = abs(obj.bandPass(obj.GLM.X)); 
			elseif ~noCtrlSig && isfield(obj.GLM, 'EMG')
				obj.GLM.gEMG = abs(obj.GLM.EMG);
				obj.iv.ctrl_signalname = 'EMG';
				obj.iv.ctrl_signaltype_ = {'EMG'};	
			else
				obj.iv.ctrl_signalname = 'none';
				obj.iv.ctrl_signaltype_ = {'none'};	
			end 
			% 
			%	Chop out the ChR2 times from the fluorescence signal
			% 
            if ~strcmp(obj.iv.signaltype_, 'camera') && ~strcmp(obj.iv.signaltype_, 'optogenetics')
                obj.GLM.rawFchop = obj.GLM.rawF;
                obj.GLM.rawFchop(obj.GLM.pos.ChR2) = nan;
            end
			% 
			% 	Execute fast gfit (10-trial baseline), which will keep nans as nans and we won't have to worry about them.
			% 
            obj.GLM.isSingleSeshObj = true;
            if strcmpi(gfitStyle{1}, 'multibaseline')
				obj.GLM.gfit = obj.normalizedMultiBaselineDFF(5000, gfitStyle{2}, obj.GLM.rawFchop);
				obj.GLM.gfitMode = '10trial norm multi baseline';
			elseif strcmpi(gfitStyle{1}, 'box')
				% 
				% 	Check if approp gfit is already in the folder:
				% 
				% 
                dirFiles = dir;
				gfitPos = find(contains({dirFiles.name},'gfit'));
				%	 
				%  If not the right kind of gfit in the sObj, acquire it from file
				%
				if isempty(gfitPos) || gfitStyle{2} ~= 200000
					warning(['gfit window entered = ' num2str(gfitStyle{2})])
					disp('		could not load gfit rv1.4 file and/or wrong type in folder, redoing from spike2file')
					if gfitStyle{2} == 200
						error('Gfit window entered as 200, but should be 200,000')
					end
					obj.GLM.gfit = obj.gfitBox(obj.GLM.rawFchop, gfitStyle{2});
                    %
                    %   Chop the ChR2 times
                    %
                    if ignoreStim
                        error('RBF')
                        obj.GLM.gfit(obj.GLM.pos.ChR2) = nan;
                    end
					obj.GLM.gfitMode = ['box', num2str(gfitStyle{2})];
					% 
				else % if we do have the gfit file preprocessed in the directory, load it up
					% 
					gfitstruct = load([dirFiles(gfitPos).folder, '\', dirFiles(gfitPos).name]);
					gfitfields = fieldnames(gfitstruct);
					try
						eval(['obj.GLM.gfit = gfitstruct.' gfitfields{1} '.gfit_signal;'])
                        if ignoreStim
                            error('RBF')
                            obj.GLM.gfit(obj.GLM.pos.ChR2) = nan;
                        end
						obj.updateLog('		gfit box200 acquired from rv1.4 file')
					catch
						warning('		could not load gfit rv1.4 file, redoing from spike2file')
						warning(['gfit window entered = ' num2str(gfitStyle{2})])
						obj.GLM.gfit = obj.gfitBox(obj.GLM.rawFchop, gfitStyle{2});
                        if ignoreStim
                            error('RBF')
                            obj.GLM.gfit(obj.GLM.pos.ChR2) = nan;
                        end
						obj.GLM.gfitMode = ['box', num2str(gfitStyle{2})];
					end
				end
			elseif strcmpi(gfitStyle{1}, 'Abs-X')
				% 
				% 	Take derivative with bandpass
				% 
				warning('not excluding stim up times for X data!')
				obj.GLM.X = obj.GLM.rawF;
				obj.GLM.rawF = [];
				obj.GLM.rawFchop = [];
				obj.GLM.gfit = abs(obj.bandPass(obj.GLM.X)); 
				obj.GLM.gfitMode = 'Abs-X';
			elseif strcmpi(gfitStyle{1}, 'Abs-Xderivative')
				% 
				% 	Take derivative as difference
				% 
				warning('not excluding stim up times for X data!')
				obj.GLM.gfit = [0;abs(obj.GLM.X(2:end)-obj.GLM.X(1:end-1))];
				obj.GLM.gfitMode = 'Abs-Xderivative';
			elseif strcmpi(gfitStyle{1}, 'EMG')
				% 
				% 	Rectify
				% 
				warning('not excluding stim up times for EMG data!')
				obj.GLM.EMG = obj.GLM.rawF;
				obj.GLM.rawFchop = [];
				obj.GLM.gfit = abs(obj.GLM.EMG); 
				obj.GLM.gfitMode = 'EMG';
			elseif strcmpi(gfitStyle{1}, 'Abs-hipass-EMG')
				% 
				% 	Rectify
				% 
				warning('not excluding stim up times for EMG data!')
				obj.GLM.EMG = obj.hiPass(obj.GLM.rawF);
				obj.GLM.rawFchop = [];
				obj.GLM.gfit = abs(obj.GLM.EMG); 
				obj.GLM.gfitMode = 'Abs-hipass-EMG';
			elseif strcmpi(gfitStyle{1}, 'Abs-bandpass-EMG')
				% 
				% 	Rectify
				% 
				warning('not excluding stim up times for EMG data!')
				obj.GLM.EMG = obj.bandPass(obj.GLM.rawF);
				obj.GLM.rawFchop = [];
				obj.GLM.gfit = abs(obj.GLM.EMG); 
				obj.GLM.gfitMode = 'Abs-bandpass-EMG';
			elseif strcmpi(gfitStyle{1}, 'Abs-CamOderivative')
                warning('RBF')
                % 
				% 	Check if approp gfit is already in the folder:
				% 
				% 
                dirFiles = dir;
				gfitPos = find(contains({dirFiles.name},'processed'));
				%	 
				%  If not the right kind of gfit in the sObj, acquire it from file
				%
				if isempty(gfitPos)
					disp('		could not load gfit rv1.4 file and/or wrong type in folder, redoing from spike2file')
                    obj.GLM.gfit = abs(obj.gfitCamera(obj.GLM.CamOtimes, obj.GLM.IRtrig));
                    % 
                    %	Append nans to the front before the camera trigger 
                    % 
                    nanpad = nan(1, find(obj.GLM.CamOtimes > obj.GLM.IRtrig, 1, 'first')-1);
                    obj.GLM.gfit = [nanpad, obj.GLM.gfit];
                    %
                    %   Chop the ChR2 times
                    %
                    if ignoreStim
                        error('RBF')
                        obj.GLM.gfit(obj.GLM.pos.ChR2) = nan;
                    end
					obj.GLM.gfitMode = 'Abs-CamOderivative';
					% 
				else % if we do have the gfit file preprocessed in the directory, load it up
					% 
					gfitstruct = load([dirFiles(gfitPos).folder, '\', dirFiles(gfitPos).name]);
					gfitfields = fieldnames(gfitstruct);
					try
						eval(['obj.GLM.gfit = abs(gfitstruct.' gfitfields{1} '.derivativeSignal);'])
						% 
	                    %	Append nans to the front before the camera trigger 
	                    % 
	                    nanpad = nan(1, find(obj.GLM.CamOtimes > obj.GLM.IRtrig, 1, 'first')-1);
	                    obj.GLM.gfit = [nanpad, obj.GLM.gfit];
						% video_struct.derivativeSignal
                        if ignoreStim
                            error('RBF')
                            obj.GLM.gfit(obj.GLM.pos.ChR2) = nan;
                        end
						obj.updateLog('		gfit camera derivative acquired from rv1.4 file')
						obj.GLM.gfitMode = 'Abs-CamOderivative';
					catch
						warning('		could not load gfit rv1.4 file, redoing from spike2file')
						obj.GLM.gfit = abs(obj.gfitCamera(obj.GLM.CamOtimes, obj.GLM.IRtrig));
						% 
	                    %	Append nans to the front before the camera trigger 
	                    % 
	                    nanpad = nan(1, find(obj.GLM.CamOtimes > obj.GLM.IRtrig, 1, 'first')-1);
	                    obj.GLM.gfit = [nanpad, obj.GLM.gfit];
                        if ignoreStim
                            error('RBF')
                            obj.GLM.gfit(obj.GLM.pos.ChR2) = nan;
                        end
						obj.GLM.gfitMode = 'Abs-CamOderivative';
					end
				end
			elseif strcmpi(gfitStyle{1}, 'ChR2')
				% 
				% 	HERE WE DO ALL THE ROADMAPV1.4 processing for ChR2!
				% 
				error('DEBUG HERE!!!!!!!!! THIS ISN''T DONE YET - need to make sure we can pop results into AutoRun and also implement methods for stat operations')
				warning('Executing roadmapv1_4 ChR2 pre-processing...')
				% 
				% 	This is what we need for the AUTO optogenetics program to run:
				% init_variables_ChR2 = optogenetics_data_struct.init_variables;
			    % h = optogenetics_data_struct.stim_struct;
			    % lick_data_struct = optogenetics_data_struct.lick_data_struct;
			    % exclusions_struct = optogenetics_data_struct.exclusions_struct;
			    % samples_per_ms_ChR2
   				%    init_variables_X = movement_data_struct.init_variables;	
			    % samples_per_ms_X = init_variables_X.time_parameters.samples_per_ms;
				% 
				% 	Honestly, it's just too hard to rewrite everything... and kinda pointless. Just process with the roadmapv1_4 method and then we will add important results from that to the obj
				% 
				% 	I'll also write methods to be able to recall the optogenetics analyses from the statObj...
				% 
				roadmap_1_4_init;
				obj.GLM.gfit = obj.GLM.ChR2values;

            else
				error('Must specify gfit style')
			end
			% 
			% 	Execute Binning...
			%
			obj.BinParams.ogBins = nbins;
			obj.Mode = Mode;
			
			[~, ~, lick_events] = histcounts(obj.GLM.lick_s, obj.GLM.cue_s);
			[fLick_trial_num, idx_event, ~] = unique(lick_events);
            
			% 
			% 	Take exclusions here
			% 
            if fLick_trial_num(1) == 0
				fLick_trial_num = fLick_trial_num(2:end);
				idx_event = idx_event(2:end);
			end
			if ~isempty(obj.iv.exclusions_struct.Excluded_Trials)
				obj.GLM.exclusionsTaken = true;
				exclIdx = find(ismember(fLick_trial_num, obj.iv.exclusions_struct.Excluded_Trials));
				fLick_trial_num(exclIdx) = [];
                idx_event(exclIdx) = [];
			end
			
			firstLick_s = obj.GLM.lick_s(idx_event);
			obj.GLM.pos.lampOff = obj.getXPositionsWRTgfit(obj.GLM.lampOff_s);
			obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);
			obj.GLM.pos.flick = obj.getXPositionsWRTgfit(firstLick_s);
			% obj.GLM.pos.fLick = round(1000*firstLick_s*obj.Plot.samples_per_ms)+1;
			obj.GLM.firstLick_s = firstLick_s;
			obj.GLM.fLick_trial_num = fLick_trial_num;
			obj.updateLog(['	Behavioral Events Acquired from Spike2 file. (' datestr(now,'HH:MM AM') ')  \n']);
			% 
			% 	Now, execute binning...
			% 
			obj.getBinnedTimeseries(obj.GLM.gfit, Mode, nbins, timePad*round(obj.Plot.samples_per_ms));
					
			obj.BinnedData = obj.ts.BinnedData;
			obj.BinParams = obj.ts.BinParams;
			obj.BinParams.ogBins = nbins;
			obj.Plot.first_post_cue_position = find(obj.ts.Plot.CTA.xticks.s > 0, 1, 'first');
			obj.Plot.lick_zero_position = find(obj.ts.Plot.LTA.xticks.s == 0);
			obj.Plot.CTA = obj.ts.Plot.CTA;
			obj.Plot.LTA = obj.ts.Plot.LTA;
			% 
			% 	Fill in these placeholders...
			% 
			obj.Plot.wrtCTAArray.Events.s.first_post_cue_position = obj.Plot.first_post_cue_position/1000;
			% 
			% 	Now, execute binning for control signal
			% 
			if ~noCtrlSig 
				if isfield(obj.GLM, 'X')
					obj.getBinnedTimeseries(obj.GLM.gX, Mode, nbins, timePad*round(obj.CtrlCh.Plot.samples_per_ms));
				elseif ~noCtrlSig && isfield(obj.GLM, 'EMG')
					obj.getBinnedTimeseries(obj.GLM.EMG, Mode, nbins, timePad*round(obj.CtrlCh.Plot.samples_per_ms));
				end
				% 
				% 	The results of binning get placed in obj.ts, so we can now transfer them to the main part of the structure
				% 
				obj.CtrlCh.BinnedData = obj.ts.BinnedData;
				obj.CtrlCh.BinParams = obj.ts.BinParams;
				obj.CtrlCh.Plot.CTA = obj.ts.Plot.CTA;
				obj.CtrlCh.Plot.CTA = obj.ts.Plot.LTA;
				obj.CtrlCh.Plot.first_post_cue_position = find(obj.ts.Plot.CTA.xticks.s > 0, 1, 'first');
				obj.CtrlCh.Plot.lick_zero_position = find(obj.ts.Plot.LTA.xticks.s == 0);
			end 

			% 
			%	Get trial stats 
			% 
			obj.iv.num_trials_category.num_no_ex_trials = obj.iv.num_trials - numel(obj.iv.exclusions_struct.Excluded_Trials);
			obj.iv.num_trials_category.num_rxn_not_ex_trials = sum(obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num) <= 0.5);
			obj.iv.num_trials_category.num_early_not_ex_trials = numel(find(obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num) > 0.5 & obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num) <= 3.33));
			obj.iv.num_trials_category.num_rew_not_ex_trials = numel(find(obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num) > 3.334 & obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num) <= 7));
			obj.iv.num_trials_category.num_ITI_not_ex_trials = numel(find(obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num) > 7 & obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num) <= 17));
			obj.iv.num_trials_category.num_no_rxn_or_ex_trials = obj.iv.num_trials_category.num_no_ex_trials - obj.iv.num_trials_category.num_rxn_not_ex_trials;
			% 
			% 	Pluck out useful trial indicies for stim/unstim
			% 
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);, end
			[~, ~, stim_events] = histcounts(obj.GLM.pos.ChR2, obj.GLM.pos.cue);
			[obj.GLM.stimTrials, ~, ~] = unique(stim_events);            
            if ~isempty(obj.GLM.stimTrials) && obj.GLM.stimTrials(1) == 0
				obj.GLM.stimTrials = obj.GLM.stimTrials(2:end);
			end
			obj.GLM.noStimTrials = find(~ismember(1:obj.iv.num_trials, obj.GLM.stimTrials));
			% 
			% 	Save the final object
			% 
			timestamp_now = datestr(now,'mm_dd_yy__HH_MM_AM');
			savefilename = [obj.iv.mousename_ '_' obj.iv.signalname{1,1} '_day' obj.iv.daynum_ '_snpObj_Mode' obj.Mode '_' num2str(obj.BinParams.nbins_CLTA) 'bins_' timestamp_now];
			save([savefilename, '.mat'], 'obj', '-v7.3');
			obj.updateLog(['Saved initiated object to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat (' datestr(now,'HH:MM AM') ') \n\n']);
			% 
			obj.updateLog(['Stat object generated and ready to use. ' datestr(now,'HH:MM AM') ') \n\n ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n\n']);
		end

		% -----------------------------------------------------
		% 				Initialize Plot parameters (verified 8/13/18)
		% -----------------------------------------------------
		function data = getPlot(obj, data, v3x)
			if nargin < 3
				v3x = false;
			end
			if ~v3x
				% 
				%   Initialize the plot-relevant variables in samples and ms
				% 
				obj.Plot.samples_per_ms = data.init_variables.time_parameters.samples_per_ms;
				obj.Plot.first_post_cue_position = data.init_variables.time_parameters.first_post_cue_position;
				if isfield(data.init_variables.time_parameters, 'lick_zero_position')
					obj.iv.setStyle = 'combined';
					obj.Plot.lick_zero_position = data.init_variables.time_parameters.lick_zero_position;
					obj.Plot.si_lick_zero_position = data.init_variables.time_parameters.si_lick_zero_position;
				else
					obj.iv.setStyle = 'single-day';
					obj.Plot.lick_zero_position = find(data.init_variables.time_parameters.LTA_time_array_ms>0, 1, 'first');
					obj.Plot.si_lick_zero_position = find(data.init_variables.time_parameters.LT_si_ITI.time_array_LT_si_ITI_ms>0, 1, 'first')
				end
				% 
				warning('Discovered critical error with samples/positions calculations for licks. Fixed here in version 2.7!')
				% 	Licks and Event Times/Positions wrt Cue Array (cue at first_post_cue_position)
				% 
				obj.Plot.wrtCTAArray.Lick.s.all_ex_first_licks = data.lick_data_struct.all_ex_first_licks;
				obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn = data.lick_data_struct.f_ex_lick_rxn;
				obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew = data.lick_data_struct.f_ex_lick_operant_no_rew;
				obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew = data.lick_data_struct.f_ex_lick_operant_rew;
				obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI = data.lick_data_struct.f_ex_lick_ITI;

				obj.Plot.wrtCTAArray.Lick.positions.all_ex_first_licks = round(obj.Plot.wrtCTAArray.Lick.s.all_ex_first_licks * 1000 * obj.Plot.samples_per_ms);
				obj.Plot.wrtCTAArray.Lick.positions.f_ex_lick_rxn = round(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn * 1000 * obj.Plot.samples_per_ms);
				obj.Plot.wrtCTAArray.Lick.positions.f_ex_lick_operant_no_rew = round(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew * 1000 * obj.Plot.samples_per_ms);
				obj.Plot.wrtCTAArray.Lick.positions.f_ex_lick_operant_rew = round(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew * 1000 * obj.Plot.samples_per_ms);
				obj.Plot.wrtCTAArray.Lick.positions.f_ex_lick_ITI = round(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI * 1000 * obj.Plot.samples_per_ms);
				
				% obj.Plot.wrtCTAArray.Lick.positions = data.init_variables.time_parameters.lick;
				% obj.Plot.wrtCTAArray.Lick.s 		= {};
				% obj.Plot.wrtCTAArray.Lick.s.lick_ex_times_by_trial = data.lick_data_struct.lick_ex_times_by_trial;
				% obj.Plot.wrtCTAArray.Lick.s.all_ex_first_licks = data.lick_data_struct.all_ex_first_licks;
				% obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn = data.lick_data_struct.f_ex_lick_rxn;
				% obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew = data.lick_data_struct.f_ex_lick_operant_no_rew;
				% obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew = data.lick_data_struct.f_ex_lick_operant_rew;
				% obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI = data.lick_data_struct.f_ex_lick_ITI;
				% 
				obj.Plot.wrtCTAArray.Events.samples = data.init_variables.time_parameters.samples_wrt_cue_array;
				% 
				obj.Plot.wrtCTAArray.Events.ms.total_time = obj.Plot.wrtCTAArray.Events.samples.total_time_samples_wrt_cue/obj.Plot.samples_per_ms;
				obj.Plot.wrtCTAArray.Events.ms.first_post_cue_position = obj.Plot.first_post_cue_position/obj.Plot.samples_per_ms;
				% 
				obj.Plot.wrtCTAArray.Events.s.total_time = obj.Plot.wrtCTAArray.Events.ms.total_time / 1000;
				obj.Plot.wrtCTAArray.Events.s.first_post_cue_position = obj.Plot.wrtCTAArray.Events.ms.first_post_cue_position / 1000;
				% 
				% 	Licks and Event Times/Positions wrt Cue (cue at 0) --- verified 8/12/18
				% 	(note: I'd like this to be one step, but can't figure out how to get this to work):
	            % 			obj.Plot.wrtCue.Lick.positions = structfun(@(x(x~=0)) x(x~=0) - obj.Plot.first_post_cue_position, obj.Plot.wrtCue.Lick.positions, 'UniformOutput', false);
				%
				%	YIKES - there was an error in the samples_wrt_cue_array calculation -- fix this here! was off by 100ms in older versions on some days... sec is more reliable (11/6/18)
				% 
				% 
				obj.Plot.wrtCue.Lick.positions = obj.Plot.wrtCTAArray.Lick.positions;
	            fields = fieldnames(obj.Plot.wrtCue.Lick.positions);
	            for fn=fields'
	              obj.Plot.wrtCue.Lick.positions.(fn{1})(obj.Plot.wrtCue.Lick.positions.(fn{1}) ~= 0) = obj.Plot.wrtCue.Lick.positions.(fn{1})(obj.Plot.wrtCue.Lick.positions.(fn{1}) ~= 0) - obj.Plot.first_post_cue_position;
	            end
				obj.Plot.wrtCue.Lick.ms 	= structfun(@(x) x/obj.Plot.samples_per_ms, obj.Plot.wrtCue.Lick.positions, 'UniformOutput', 0);
				obj.Plot.wrtCue.Lick.s 		= structfun(@(x) x/1000, obj.Plot.wrtCue.Lick.ms, 'UniformOutput', 0);
				% 
				obj.Plot.wrtCue.Events.ms 	= data.init_variables.time_parameters.ms;
				obj.Plot.wrtCue.Events.s 	= structfun(@(x) x/1000, obj.Plot.wrtCue.Events.ms, 'UniformOutput', 0);
				obj.Plot.wrtCue.Events.samples = data.init_variables.time_parameters.samples_wrt_cue;  
				% 
				% 	X-ticks and size of CTA (verified 8/12/18)
				% 
				obj.Plot.CTA.xticks.samples = data.init_variables.time_parameters.time_array_CTA_samples;
				obj.Plot.CTA.xticks.ms 		= data.init_variables.time_parameters.time_array_CTA_ms;
				obj.Plot.CTA.xticks.s 		= obj.Plot.CTA.xticks.ms / 1000;
				if strcmp(obj.iv.setStyle, 'combined')
					obj.Plot.CTA.size 			= data.init_variables.time_parameters.size.CTA_samples; 
				elseif strcmp(obj.iv.setStyle, 'single-day')
					obj.Plot.CTA.size 			= numel(data.init_variables.time_parameters.time_array_CTA_ms); 
				end
				% 
				% 	X-ticks and size of LTA (verified 8/12/18)
				%
				obj.Plot.LTA.xticks.samples = data.init_variables.time_parameters.LTA_time_array_samples;
				obj.Plot.LTA.xticks.ms 		= data.init_variables.time_parameters.LTA_time_array_ms;
				obj.Plot.LTA.xticks.s 		= obj.Plot.LTA.xticks.ms / 1000;
				if strcmp(obj.iv.setStyle, 'combined')
					obj.Plot.LTA.size 		= data.init_variables.time_parameters.size.LTA_samples;
				elseif strcmp(obj.iv.setStyle, 'single-day')
					obj.Plot.LTA.size 		= numel(data.init_variables.time_parameters.LTA_time_array_samples); 
				end
				% 
				% 	siITI is calc'd without exclusions in o.g. analysis, so fix that here: (validated 8/13/18)
				% 
				data = obj.fixSiITI(data);
				%
            else   	
				% 
				%   Initialize the plot-relevant variables. These will depend on the spike2 file, and we will calc from scratch
				% 
				if strcmp(obj.iv.signaltype_, 'photometry')
					if isfield(obj.GLM, 'gtimes')
						obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.gtimes(2:end) - obj.GLM.gtimes(1:end-1)));
						if obj.Plot.samples_per_ms > 1.000000001 || obj.Plot.samples_per_ms < 0.99999999999
							obj.iv.FLAG = 1; 
							warning('Dataset flagged for unexpected photometry sampling rate!')
						end
					else
						obj.Plot.samples_per_ms = [];
					end
					obj.Plot.smooth_kernel = 100;
				elseif strcmpi(obj.iv.signaltype_, 'camera')
					if isfield(obj.GLM, 'CamOtimes')
						obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.CamOtimes(2:end) - obj.GLM.CamOtimes(1:end-1)));
					else
						obj.Plot.samples_per_ms = [];
                        warning('check this!')
					end
					obj.Plot.smooth_kernel = 3;
					warning('check this!')
				elseif strcmpi(obj.iv.signaltype_, 'optogenetics')
					warning('RBF')
					if isfield(obj.GLM, 'ChR2times')
						obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.ChR2times(2:end) - obj.GLM.ChR2times(1:end-1)));
						if obj.Plot.samples_per_ms > 1.000000001 || obj.Plot.samples_per_ms < 0.99999999999
							obj.iv.FLAG = 1; 
							warning('Dataset flagged for unexpected ChR2 sampling rate!')
						end
					else
						obj.Plot.samples_per_ms = [];
                        warning('RBF!')
                    end
					obj.Plot.smooth_kernel = 1;
				else
					if isfield(obj.GLM, 'Xtimes')
						obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.Xtimes(2:end) - obj.GLM.Xtimes(1:end-1)));
						if obj.Plot.samples_per_ms > 2.000000001 || obj.Plot.samples_per_ms < 1.99999999999
							obj.iv.FLAG = 1; 
							warning('Dataset flagged for unexpected X sampling rate!')
						end
					elseif isfield(obj.GLM, 'EMGtimes')
						obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.EMGtimes(2:end) - obj.GLM.EMGtimes(1:end-1)));
						if obj.Plot.samples_per_ms > 2.000000001 || obj.Plot.samples_per_ms < 1.99999999999
							obj.iv.FLAG = 1; 
							warning('Dataset flagged for unexpected EMG sampling rate!')
						end
					else
						warning('Warning - may not be implemented...!')
						obj.Plot.samples_per_ms = [];
					end
					obj.Plot.smooth_kernel = 200;
				end

				if strcmp(obj.iv.ctrl_signaltype_{1}, 'photometry')
					error('not implemented, add .cGtimes to init processing...')
					obj.CtrlCh.Plot.samples_per_ms =1/(1000*mean(obj.GLM.cGtimes(2:end) - obj.GLM.cGtimes(1:end-1)));
					if obj.CtrlCh.Plot.samples_per_ms > 1.000000001 || obj.CtrlCh.Plot.samples_per_ms < 0.99999999999
							obj.iv.FLAG = 1; 
							warning('Dataset flagged for unexpected photometry sampling rate!')
						end
					obj.CtrlCh.Plot.smooth_kernel = 100;
				elseif strcmp(obj.iv.ctrl_signaltype_{1}, 'camera')
					obj.CtrlCh.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.CamOtimes(2:end) - obj.GLM.CamOtimes(1:end-1)));
					obj.CtrlCh.Plot.smooth_kernel = 3;
					warning('check this!')
				else
					if isfield(obj.GLM, 'Xtimes')
						obj.CtrlCh.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.Xtimes(2:end) - obj.GLM.Xtimes(1:end-1)));
						if obj.CtrlCh.Plot.samples_per_ms > 2.000000001 || obj.CtrlCh.Plot.samples_per_ms < 1.99999999999
							obj.iv.FLAG = 1; 
							warning('Dataset flagged for unexpected X sampling rate!')
						end
					elseif isfield(obj.GLM, 'EMGtimes')
						obj.CtrlCh.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.EMGtimes(2:end) - obj.GLM.EMGtimes(1:end-1)));
						if obj.CtrlCh.Plot.samples_per_ms > 2.0000000001 || obj.CtrlCh.Plot.samples_per_ms < 1.99999999999
							obj.iv.FLAG = 1; 
							warning('Dataset flagged for unexpected EMG sampling rate!')
						end
					else
						obj.CtrlCh.Plot.samples_per_ms = [];
					end
					obj.CtrlCh.Plot.smooth_kernel = 200;
				end

				obj.iv.correctedSamplingRate = datestr(now);

			end
		end

		function correctSamplingRate(obj)
			if strcmp(obj.iv.signaltype_, 'photometry')
				if isfield(obj.GLM, 'gtimes')
					obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.gtimes(2:end) - obj.GLM.gtimes(1:end-1)));
					if obj.Plot.samples_per_ms > 1.000000001 || obj.Plot.samples_per_ms < 0.99999999999
						obj.iv.FLAG = 1; 
						warning('Dataset flagged for unexpected photometry sampling rate!')
					end
				else
					obj.Plot.samples_per_ms = [];
				end
				obj.Plot.smooth_kernel = 100;
			elseif strcmp(obj.iv.signaltype_, 'camera')
				if isfield(obj.GLM, 'CamOtimes')
					obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.CamOtimes(2:end) - obj.GLM.CamOtimes(1:end-1)));
				else
					error('Not implemented!')
					obj.Plot.samples_per_ms = [];
				end
				obj.Plot.smooth_kernel = 3;
				warning('check this!')
			else
				if isfield(obj.GLM, 'Xtimes')
					obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.Xtimes(2:end) - obj.GLM.Xtimes(1:end-1)));
					if obj.Plot.samples_per_ms > 2.000000001 || obj.Plot.samples_per_ms < 1.99999999999
						obj.iv.FLAG = 1; 
						warning('Dataset flagged for unexpected X sampling rate!')
					end
				elseif isfield(obj.GLM, 'EMGtimes')
					obj.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.EMGtimes(2:end) - obj.GLM.EMGtimes(1:end-1)));
					if obj.Plot.samples_per_ms > 2.000000001 || obj.Plot.samples_per_ms < 1.99999999999
						obj.iv.FLAG = 1; 
						warning('Dataset flagged for unexpected EMG sampling rate!')
					end
				else
					error('Not implemented!')
					obj.Plot.samples_per_ms = [];
				end
				obj.Plot.smooth_kernel = 200;
            end
            if isfield(obj.iv, 'ctrl_signaltype_')
                if strcmp(obj.iv.ctrl_signaltype_{1}, 'photometry')
                    error('not implemented, add .cGtimes to init processing...')
                    obj.CtrlCh.Plot.samples_per_ms =1/(1000*mean(obj.GLM.cGtimes(2:end) - obj.GLM.cGtimes(1:end-1)));
                    if obj.CtrlCh.Plot.samples_per_ms > 1.000000001 || obj.CtrlCh.Plot.samples_per_ms < 0.99999999999
                            obj.iv.FLAG = 1; 
                            warning('Dataset flagged for unexpected photometry sampling rate!')
                        end
                    obj.CtrlCh.Plot.smooth_kernel = 100;
                elseif strcmp(obj.iv.ctrl_signaltype_{1}, 'camera')
                    obj.CtrlCh.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.CamOtimes(2:end) - obj.GLM.CamOtimes(1:end-1)));
                    obj.CtrlCh.Plot.smooth_kernel = 3;
                    warning('check this!')
                else
                    if isfield(obj.GLM, 'Xtimes')
                        obj.CtrlCh.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.Xtimes(2:end) - obj.GLM.Xtimes(1:end-1)));
                        if obj.CtrlCh.Plot.samples_per_ms > 2.000000001 || obj.CtrlCh.Plot.samples_per_ms < 1.99999999999
                            obj.iv.FLAG = 1; 
                            warning('Dataset flagged for unexpected X sampling rate!')
                        end
                    elseif isfield(obj.GLM, 'EMGtimes')
                        obj.CtrlCh.Plot.samples_per_ms = 1/(1000*mean(obj.GLM.EMGtimes(2:end) - obj.GLM.EMGtimes(1:end-1)));
                        if obj.CtrlCh.Plot.samples_per_ms > 2.0000000001 || obj.CtrlCh.Plot.samples_per_ms < 1.99999999999
                            obj.iv.FLAG = 1; 
                            warning('Dataset flagged for unexpected EMG sampling rate!')
                        end
                    else
                        obj.CtrlCh.Plot.samples_per_ms = [];
                    end
                    obj.CtrlCh.Plot.smooth_kernel = 200;
                end
            end
			obj.iv.correctedSamplingRate = datestr(now);
            disp(['SAMPLING RATE CORRECTED (' datestr(now) ') - save file if desired...'])

		end

		function generateLog(obj)
			todays_date = date;
			obj.Log.fid_name = ['StatObj Log ', todays_date, '_' datestr(now,'HH.MM')];
			obj.Log.log_data = ['Statistical Object log 1.0 \n\n Generated on ', todays_date, '\n\n ------------------------------------------------------------------ \n\n'];
			obj.Log.f_log = figure('Name', 'StatObj Log', 'Units', 'normalized', 'Position', [.68,0.2,0.3,.7]);


			obj.Log.log_str = uicontrol('Parent',obj.Log.f_log,...
			          'Units','normalized',...
			          'Position',[0.1,0.1,0.8,0.8],...
			          'Style','edit',...
			          'Max',100,...
			          'Enable','on',...
			          'HorizontalAlignment', 'left',...
			          'String',sprintf(obj.Log.log_data));
			disp('============================= Generating Stat Obj ===================================')
		end

		function updateLog(obj, inputstr)
			obj.Log.log_data = [obj.Log.log_data, inputstr];
			obj.Log.log_str.String = sprintf(obj.Log.log_data);
            fid=fopen(obj.Log.fid_name,'w');
            fprintf(fid, obj.Log.log_data);
            fclose(fid);
            % 
            % 	Display the log text in Matlab...
            % 
            disp(sprintf(inputstr));
		end


		function data = fixSiITI(obj, data) 	% validated 8/13/18
			obj.updateLog(['Correcting siITI for exclusions... (' datestr(now,'HH:MM AM') ') \n']);
			% 
			num_trials = data.init_variables.num_trials;
			signal_vbt = data.signal_ex_values_by_trial;
			lick_times_by_trial = data.lick_data_struct.lick_ex_times_by_trial;
			init_variables = data.init_variables;
			no_lick_zone_in_sec = 1;
			% 
			% 
			%% 	0. Initilize containers
			% 
			% 	These will keep in times by trial format
			% 
			si_lick_ITI_samples_by_trial = zeros(num_trials, 1);
			si_lick_ITI_s_by_trial       = zeros(num_trials, 1);
			% 
			% 	These will make each si ITI lick its own "trial"
			% 
			trial_markers.trial_number           = nan(num_trials,1);
			trial_markers.si_ITI_lick_in_samples = nan(num_trials,1);
			trial_markers.si_ITI_lick_in_s 		 = nan(num_trials,1);
			% 
			% 
			%%	1. Convert lick_times_by_trial into samples 
			% 
			zero_positions = find(lick_times_by_trial == 0);
			lick_samples_by_trial = round(lick_times_by_trial * init_variables.time_parameters.samples_per_ms * 1000);
			lick_samples_by_trial(zero_positions) = 0;
			% 
			% 
			% 	2. Determine the ITI window of positions and how many samples surrounding should not have lick
			% 
			window_min = init_variables.time_parameters.samples_wrt_cue_array.ITI_time_samples_wrt_cue;
			window_max = init_variables.time_parameters.samples_wrt_cue_array.total_time_samples_wrt_cue;
			no_lick_zone_in_samples = no_lick_zone_in_sec*(init_variables.time_parameters.samples_per_ms * 1000);
			% 
			% 
			% 	3. Find all licks that satisfy these boundaries AND have no other lick within 1 sec of them
			% 			We will also track how far from the previous lick each lick is. The max is 
			% 
			samples_from_prior_lick = nan(num_trials, 1);
			sec_from_prior_lick     = nan(num_trials, 1);
			% 
			%  Also track the number of si ITI licks
			% 
			num_si_ITI_licks_total = 0;
			% 
			% 
			for i_trial = 1:num_trials
				num_si_licks_this_trial = 0;
				% 
				% 	Find all lick_times_by_trial positions in current trial that fall in the ITI
				% 
				ITI_lick_positions = find(lick_samples_by_trial(i_trial, :) > window_min & lick_samples_by_trial(i_trial, :) < window_max);
				% 
				% 	For each ITI lick, determine if lick is not preceeded by lick within <= no_lick_zone time on the left
				% 
				for i_licks = 1:length(ITI_lick_positions)
					% 
					% 	If this is the 1st ITI lick OR if this lick is not preceeded by another lick in the trial by >= no_lick_zone
					% 
					if ITI_lick_positions(i_licks) == 1 || lick_samples_by_trial(i_trial, ITI_lick_positions(i_licks)) > (lick_samples_by_trial(i_trial, ITI_lick_positions(i_licks)-1) + no_lick_zone_in_samples)
						num_si_licks_this_trial = num_si_licks_this_trial + 1;
						num_si_ITI_licks_total  = num_si_ITI_licks_total + 1;
						si_lick_ITI_samples_by_trial(i_trial, num_si_licks_this_trial) = lick_samples_by_trial(i_trial, ITI_lick_positions(i_licks));
						si_lick_ITI_s_by_trial(i_trial, num_si_licks_this_trial) 	   = lick_times_by_trial(i_trial, ITI_lick_positions(i_licks));
			   			% 
						%  While we are at at, make an array of si licks with trial markers, since we can have multiple SI licks per trial
						% 
						trial_markers.trial_number(num_si_ITI_licks_total) 		  	 = i_trial;
					    trial_markers.si_ITI_lick_in_samples(num_si_ITI_licks_total) = lick_samples_by_trial(i_trial, ITI_lick_positions(i_licks));
						trial_markers.si_ITI_lick_in_s(num_si_ITI_licks_total) 		 = lick_times_by_trial(i_trial, ITI_lick_positions(i_licks));
						% 
						% 	If it's the first ITI lick, might also be 1st lick in trial. If so, need to say lick separated by >= time since the cue
						% 
						if ITI_lick_positions(i_licks) == 1 % i.e., if this is the first lick in the trial...
							% 
							% If there are no non-ITI licks in trial, the max known time since last lick is time to cue
							% Thus 7 sec should be read as >= 7 sec. However, some ITI licks will be >7s, so basically anything >7 sec all bets are off
							% 
							% However, I doubt we would bin by times > 7 sec, so this is ok for now. (1/6/18)
							% 
							samples_from_prior_lick(num_si_ITI_licks_total) = lick_samples_by_trial(i_trial, ITI_lick_positions(i_licks)) - init_variables.time_parameters.samples_wrt_cue_array.cue_on_time_samples_wrt_cue;
							sec_from_prior_lick(num_si_ITI_licks_total)     = init_variables.time_parameters.ms.ITI_time_ms * 1000;
						else
							% 
							% 	Otherwise, find the distance from prior lick in samples and time
							% 
							samples_from_prior_lick(num_si_ITI_licks_total) = lick_samples_by_trial(i_trial, ITI_lick_positions(i_licks)) - lick_samples_by_trial(i_trial, ITI_lick_positions(i_licks)-1);
							sec_from_prior_lick(num_si_ITI_licks_total)	    = lick_times_by_trial(i_trial, ITI_lick_positions(i_licks)) - lick_times_by_trial(i_trial, ITI_lick_positions(i_licks)-1);
						end
					else
						% 
						% This lick gets excluded from consideration, do nothing
						% 
					end
				end
			end
			% 
			% 	Trim off nans from the trial markers for easier parsing:
			% 
			if ~isempty(find(isnan(trial_markers.trial_number), 1))
				keep_pos = find(trial_markers.trial_number > -1000);
				trial_markers.trial_number 			 = trial_markers.trial_number(keep_pos);
				trial_markers.si_ITI_lick_in_samples = trial_markers.si_ITI_lick_in_samples(keep_pos);
				trial_markers.si_ITI_lick_in_s  	 = trial_markers.si_ITI_lick_in_s(keep_pos);
				samples_from_prior_lick 			 = samples_from_prior_lick(keep_pos);
				sec_from_prior_lick					 = sec_from_prior_lick(keep_pos);
			end
			% 
			%  (prior sections valifated 1/4/18)
			% 
			%% For each ITI self-init lick, create a lick-triggered dataset, keeping track of how far from prior lick
			%		Thus, binning will be much easier!
			% 
			% num_si_ITI_licks_total = sum(sum((si_lick_ITI_samples_by_trial > 0)));
			samples_from_prior_lick_LT = nan(num_si_ITI_licks_total,1);
			samples_per_trial = obj.Plot.CTA.size; %size(data.signal_ex_values_by_trial, 2);
			samples_right_of_and_lick = init_variables.time_parameters.samples_wrt_cue.total_time_samples_wrt_cue - init_variables.time_parameters.samples_wrt_cue.ITI_time_samples_wrt_cue;
			samples_left_of_lick = samples_per_trial;
			% 	
			% 	Unlike the other datasets, no need to back-fill because we already have 7 sec of data at least for each trial:
			% 
			%	4. Fill containers of left_of_lick and right_of_and_lick
			% 
			right_of_and_lick = NaN(num_si_ITI_licks_total, samples_right_of_and_lick);
			left_of_lick 	  = NaN(num_si_ITI_licks_total, samples_left_of_lick);
			% 
			% 	Go thru the array of si lick times [samples] and align the data
			% 
			for i_lick = 1:num_si_ITI_licks_total
				trial_num 	  = trial_markers.trial_number(i_lick);
				lick_position = trial_markers.si_ITI_lick_in_samples(i_lick);
				right_of_and_lick(i_lick, 1:samples_per_trial-lick_position + 1) = signal_vbt(trial_num, lick_position:end); 
				ll_l 															 = samples_per_trial-(lick_position-1) + 1;
				left_of_lick(i_lick, ll_l:end)									 = signal_vbt(trial_num, 1:lick_position-1);
			end		
			% 
			% 	Finalize the new analog value array and make time arrays
			% 
			LT_si_ITI = horzcat(left_of_lick, right_of_and_lick);
			time_array_LT_si_ITI_samples(1:samples_left_of_lick) 	  = -samples_left_of_lick:-1;
			time_array_LT_si_ITI_samples(samples_left_of_lick+1 : samples_left_of_lick + samples_right_of_and_lick) = 0:samples_right_of_and_lick - 1;
			% 
			time_array_LT_si_ITI_ms = time_array_LT_si_ITI_samples ./ init_variables.time_parameters.samples_per_ms;
			% 
			% 	5. Build the LT_si_ITI_struct and other returned variables
			%
			LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial 		  	= LT_si_ITI;
			LT_si_ITI_struct.by_trial.si_lick_ITI_samples_by_trial	= si_lick_ITI_samples_by_trial;
			LT_si_ITI_struct.by_trial.si_lick_ITI_s_by_trial 	   	= si_lick_ITI_s_by_trial;
			% 
			LT_si_ITI_struct.LT_si_ITI_ave 				  		  	= nanmean(LT_si_ITI);
			% 
			LT_si_ITI_struct.trial_markers				  		   	= trial_markers;
			% 
			LT_si_ITI_struct.plotting_times.samples_from_prior_lick = samples_from_prior_lick;
			LT_si_ITI_struct.plotting_times.sec_from_prior_lick		= sec_from_prior_lick;
			% 
			% 
			init_variables.time_parameters.LT_si_ITI.time_array_LT_si_ITI_samples = time_array_LT_si_ITI_samples;
			init_variables.time_parameters.LT_si_ITI.time_array_LT_si_ITI_ms 	  = time_array_LT_si_ITI_ms;
			% 
			% 	X-ticks, Lick positions/times and size of siITI
			% 
			obj.Plot.siITI.xticks.samples = init_variables.time_parameters.LT_si_ITI.time_array_LT_si_ITI_samples;
			obj.Plot.siITI.xticks.ms 	= init_variables.time_parameters.LT_si_ITI.time_array_LT_si_ITI_ms;
			obj.Plot.siITI.xticks.s 	= obj.Plot.siITI.xticks.ms / 1000;
			% 
			obj.Plot.siITI.Lick.trial_numbers = trial_markers.trial_number;
			% 
			obj.Plot.siITI.Lick.samples.wrtCue = LT_si_ITI_struct.trial_markers.si_ITI_lick_in_samples;
			obj.Plot.siITI.Lick.samples.wrtLastLick = LT_si_ITI_struct.plotting_times.samples_from_prior_lick;
			% 
			obj.Plot.siITI.Lick.ms.wrtCue = obj.Plot.siITI.Lick.samples.wrtCue / obj.Plot.samples_per_ms;
			obj.Plot.siITI.Lick.ms.wrtLastLick = obj.Plot.siITI.Lick.samples.wrtLastLick / obj.Plot.samples_per_ms;
			% 
			obj.Plot.siITI.Lick.s.wrtCue = LT_si_ITI_struct.trial_markers.si_ITI_lick_in_s;
			obj.Plot.siITI.Lick.s.wrtLastLick = obj.Plot.siITI.Lick.ms.wrtLastLick / 1000;
			%
			if strcmp(obj.iv.setStyle, 'combined')
				obj.Plot.siITI.size 		= data.init_variables.time_parameters.size.si_ITI_samples;
			elseif strcmp(obj.iv.setStyle, 'single-day')
				obj.Plot.siITI.size 		= numel(data.init_variables.time_parameters.LT_si_ITI.time_array_LT_si_ITI_ms);
			end
			% 
			% 	Finally, update the data's siITI
			% 
			if obj.Plot.siITI.size == size(LT_si_ITI, 2)
				data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial = LT_si_ITI;
			else
				warning('Size of new siITI dataset differed from o.g. Replacing now...')
				data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial = LT_si_ITI;
				obj.Plot.siITI.size = size(LT_si_ITI, 2);
			end
		end

		% -----------------------------------------------------
		% 				Combine datasets into bins
		%
		%	Times verified for 1 and multiple bins: 8/12/18
		% 	Trials verified for 1+ bins: 8/16/18
		% -----------------------------------------------------
		function getBinnedData(obj, data)
			warning('CHECK BIN CENTERS IN CLTA/siITI!!!!!!!!! May be an error (11/1/18)')
			if strcmpi(obj.Mode, 'Times') && ~obj.Stim.stimobj
				obj.updateLog(['Attempting to bin data with even blocks of time... (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Divide the total trial time into equal sized bins of time
				% 		e.g., 17 bins = [0:1s], [1s:2s], ... , [16s:17s]
				% 	We will allow the last time bin to be smaller than the rest
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				nbins = obj.BinParams.ogBins;
				time_per_bin_ms = obj.iv.total_time_ / nbins;
				binEdges = 1:time_per_bin_ms:obj.iv.total_time_;
                % Make sure we have the right number of bins...
                if length(binEdges) < nbins + 1
                    binEdges(end+1) = obj.iv.total_time_;
                end
				obj.updateLog(['nbins: ' num2str(nbins) ' || time per bin (ms): ' num2str(time_per_bin_ms) ' || binEdges: ' mat2str(binEdges) ' \n']);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                all_fl_wrtc_ms = nansum(all_fl_wrtc_ms, 3); 
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				for ibin = 1:nbins
					if abs(rem(nbins*.10, ibin)) < 0.5
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					end
					ll = find(all_fl_wrtc_ms >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
					trials_in_each_bin(ibin).CTA =  ll(ismember(ll, ul));
					trials_in_each_bin(ibin).LTA = trials_in_each_bin(ibin).CTA;
					ll = find(obj.Plot.siITI.Lick.ms.wrtLastLick >= binEdges(ibin));
					ul = find(obj.Plot.siITI.Lick.ms.wrtLastLick < binEdges(ibin + 1));
					trials_in_each_bin(ibin).siITI = ll(ismember(ll, ul));
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).CTA, :), 1);
                    if isfield(data, 'signal_ex_values_up_to_lick')
    					obj.BinnedData.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).CTA,:), 1); 
                    else
                        obj.BinnedData.CTAtoLick{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).CTA,:), 1); 
                    end
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.LTA(ibin).All = cat(3, obj.BinnedData.LTA(ibin).rxn, obj.BinnedData.LTA(ibin).early, obj.BinnedData.LTA(ibin).rew, obj.BinnedData.LTA(ibin).ITI);
					obj.BinnedData.LTA(ibin).All = nanmean(obj.BinnedData.LTA(ibin).All, 3);
					% 
					% 	siITI
					% 
					obj.BinnedData.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					obj.BinParams.Legend_s.siITI{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
					obj.BinParams.s(ibin).siITI_Min = binEdges(ibin)/1000;
					obj.BinParams.s(ibin).siITI_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.s(ibin).siITI_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.BinParams.binEdges_CLTA = binEdges;
                obj.BinParams.binEdges_siITI = binEdges;
                obj.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.nbins_CLTA = nbins;
                obj.BinParams.nbins_siITI = nbins;


				

			elseif strcmpi(obj.Mode, 'Trials') && ~obj.Stim.stimobj
				obj.updateLog(['Attempting to bin data with even numbers of trials... (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Divide the total number of trials into equal sized bins of trials
				% 		e.g., 5000 trials = [1:500], [501:1000], ... , [4501:5000]
				% 	We will allow the last trial bin to be smaller than the rest
				% 		*** IN THIS CASE, nbins will refer to number of TRIALS per bin
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				ntrials_per_bin = obj.BinParams.ogBins;
				if strcmp(obj.BinParams.ogBins, 'all')
					nbins_CLTA = 1;
					nbins_siITI = 1;
					ntrials_per_bin_CLTA = obj.iv.num_trials;
					ntrials_per_bin_siITI = obj.iv.num_si_ITI_licks;
					binEdges_CLTA = [1,obj.iv.num_trials];
					binEdges_siITI = [1,obj.iv.num_si_ITI_licks];
				elseif obj.BinParams.ogBins == 1
					%  The last bin will have fewer trials
					nbins_CLTA = ceil(obj.iv.num_trials/obj.BinParams.ogBins);
					nbins_siITI = ceil(obj.iv.num_si_ITI_licks/obj.BinParams.ogBins);
					ntrials_per_bin_CLTA = ntrials_per_bin;
					ntrials_per_bin_siITI = ntrials_per_bin;
					binEdges_CLTA = 1:ntrials_per_bin_CLTA:obj.iv.num_trials+1;
					if binEdges_CLTA(end) ~= obj.iv.num_trials
						binEdges_CLTA(end+1) = obj.iv.num_trials;
					end
					binEdges_siITI = 1:ntrials_per_bin_CLTA:obj.iv.num_si_ITI_licks+1;
					if binEdges_siITI(end) ~= obj.iv.num_si_ITI_licks
						binEdges_siITI(end+1) = obj.iv.num_si_ITI_licks;
					end
					
				else
					%  The last bin will have fewer trials
					nbins_CLTA = ceil(obj.iv.num_trials/obj.BinParams.ogBins);
					nbins_siITI = ceil(obj.iv.num_si_ITI_licks/obj.BinParams.ogBins);
					ntrials_per_bin_CLTA = ntrials_per_bin;
					ntrials_per_bin_siITI = ntrials_per_bin;
					binEdges_CLTA = 1:ntrials_per_bin_CLTA:obj.iv.num_trials;
					if binEdges_CLTA(end) ~= obj.iv.num_trials
						binEdges_CLTA(end+1) = obj.iv.num_trials;
					end
					binEdges_siITI = 1:ntrials_per_bin_CLTA:obj.iv.num_si_ITI_licks;
					if binEdges_siITI(end) ~= obj.iv.num_si_ITI_licks
						binEdges_siITI(end+1) = obj.iv.num_si_ITI_licks;
					end
				end

				obj.updateLog(['nbins-CLTA: ' num2str(nbins_CLTA) '|| nbins-siITI: ' num2str(nbins_siITI) ' || # trials per bin (ms): ' num2str(ntrials_per_bin) ' || binEdges-CLTA: ' mat2str(binEdges_CLTA) ' || binEdges-siITI: ' mat2str(binEdges_siITI) ' \n']);
				% 
				% 	Next, we will need to sort the lick times
				% 
                warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                all_fl_wrtc_ms = nansum(all_fl_wrtc_ms, 3); 
				all_fl_wrtc_ms = [all_fl_wrtc_ms; 1:obj.iv.num_trials];
				sorted_lt_wrtc_ms = sortrows(all_fl_wrtc_ms',1)';

				all_siITI_wrtLastLick_ms = [obj.Plot.siITI.Lick.ms.wrtLastLick' ; 1:obj.iv.num_si_ITI_licks];
				sorted_siITI_wrtLastLick_ms = sortrows(all_siITI_wrtLastLick_ms',1)';
				obj.updateLog(['Lick times sorted. (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Now binning is simple...
				% 		CTA 				LTA 				siITI
				% 1| 	1:500 sorted_lt	 	1:500 sorted_lt		1:500 sorted_siITI
				% 2| 	501:1000 sorted_lt	501:1000 sorted_lt	501:1000 sorted_siITI
				% ...
				% 
				trials_in_each_bin = {};
                % trials_in_each_bin(1:nbins).CTA = []; 
                % trials_in_each_bin(1:nbins).LTA = [];
                % trials_in_each_bin(1:nbins).siITI = [];
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				for ibin = 1:nbins_CLTA
					if abs(rem(nbins_CLTA*.10, ibin)) < 0.5
						disp(['Processing CTLA bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					end
					trials_in_each_bin(ibin).CTA = sorted_lt_wrtc_ms(2, binEdges_CLTA(ibin):binEdges_CLTA(ibin+1)-1);
					trials_in_each_bin(ibin).LTA = trials_in_each_bin(ibin).CTA;
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).CTA, :), 1);
					if isfield(data, 'signal_ex_values_up_to_lick')
                        obj.BinnedData.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).CTA, :), 1); 
                    else
                        %pass
                    end                        % 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.LTA(ibin).All = cat(3, obj.BinnedData.LTA(ibin).rxn, obj.BinnedData.LTA(ibin).early, obj.BinnedData.LTA(ibin).rew, obj.BinnedData.LTA(ibin).ITI);
					obj.BinnedData.LTA(ibin).All = nanmean(obj.BinnedData.LTA(ibin).All, 3); 
	                % 
					% 	Append the legend
					% 
					obj.BinParams.Legend_s.CLTA{ibin} = [num2str(round(sorted_lt_wrtc_ms(1, binEdges_CLTA(ibin))/1000,3)), 's - ', num2str(round(sorted_lt_wrtc_ms(1, binEdges_CLTA(ibin+1)-1)/1000,3)), 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.s(ibin).CLTA_Min = sorted_lt_wrtc_ms(1, binEdges_CLTA(ibin))/1000;
					obj.BinParams.s(ibin).CLTA_Max = sorted_lt_wrtc_ms(1, binEdges_CLTA(ibin+1)-1)/1000;
					obj.BinParams.s(ibin).CLTA_Center = (obj.BinParams.s(ibin).CLTA_Min + (obj.BinParams.s(ibin).CLTA_Max - obj.BinParams.s(ibin).CLTA_Min)/2);
					% 
                end
				for ibin = 1:nbins_siITI
					if abs(rem(nbins_siITI*.10, ibin)) < 0.5
						disp(['Processing siITI bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					end
					% 
					% 	siITI
					% 
					trials_in_each_bin(ibin).siITI = sorted_siITI_wrtLastLick_ms(2, binEdges_siITI(ibin):binEdges_siITI(ibin+1)-1);
					obj.BinnedData.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.Legend_s.siITI{ibin} = [num2str(round(sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin))/1000,3)) 's - ' num2str(round(sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin+1)-1)/1000,3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.s(ibin).siITI_Min = sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin))/1000;
					obj.BinParams.s(ibin).siITI_Max = sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin+1)-1)/1000;
					obj.BinParams.s(ibin).siITI_Center = (obj.BinParams.s(ibin).siITI_Min + (obj.BinParams.s(ibin).siITI_Max - obj.BinParams.s(ibin).siITI_Min)/2);
					%
				end
                obj.BinParams.binEdges_CLTA = binEdges_CLTA;
                obj.BinParams.binEdges_siITI = binEdges_siITI;
                obj.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.ntrials_per_bin_CLTA = ntrials_per_bin_CLTA;
				obj.BinParams.ntrials_per_bin_siITI = ntrials_per_bin_siITI;
				obj.BinParams.nbins_CLTA = nbins_CLTA;
                obj.BinParams.nbins_siITI = nbins_siITI;
            % 
            % 
            % 					OUTCOME MODE
            % 	
            % 
			elseif strcmpi(obj.Mode, 'Outcome') && ~obj.Stim.stimobj
				obj.updateLog(['Attempting to bin data by outcome... (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	There will be only 6 bins - one for each category and 2 bufferzones
				% 
				disp('Note that the reward boundary (3333ms) is not well defined, so bin 4 is 3330-3332 to avoid overlap of rew and unrewarded lost in sampling...')
				nbins = obj.BinParams.ogBins;
				rxnmax = data.init_variables.time_parameters.ms.rxn_time_ms;
				rxnbuffer = 700;
				earlymax = 3330;
				rewbuffer = 3333;
				rewardmax = data.init_variables.time_parameters.ms.ITI_time_ms+1;
				itimax = data.init_variables.time_parameters.ms.total_time_ms+1;
				binEdges = [1, rxnmax, rxnbuffer, earlymax, rewbuffer, rewardmax, itimax];
                % Make sure we have the right number of bins...
				obj.updateLog(['nbins: ' num2str(nbins) ' || binEdges: ' mat2str(binEdges) ' \n']);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                % warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                all_fl_wrtc_ms = nansum(all_fl_wrtc_ms, 3); 
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				for ibin = 1:nbins
					disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					ll = find(all_fl_wrtc_ms >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
					trials_in_each_bin(ibin).CTA =  ll(ismember(ll, ul));
					trials_in_each_bin(ibin).LTA = trials_in_each_bin(ibin).CTA;
					ll = find(obj.Plot.siITI.Lick.ms.wrtLastLick >= binEdges(ibin));
					ul = find(obj.Plot.siITI.Lick.ms.wrtLastLick < binEdges(ibin + 1));
					trials_in_each_bin(ibin).siITI = ll(ismember(ll, ul));
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).CTA, :), 1);
                    if isfield(data, 'signal_ex_values_up_to_lick')
    					obj.BinnedData.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).CTA,:), 1); 
                    else
                        obj.BinnedData.CTAtoLick{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).CTA,:), 1); 
                    end
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						error('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).LTA, :), 1);
					else
						obj.BinnedData.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.LTA(ibin).All = cat(3, obj.BinnedData.LTA(ibin).rxn, obj.BinnedData.LTA(ibin).early, obj.BinnedData.LTA(ibin).rew, obj.BinnedData.LTA(ibin).ITI);
					obj.BinnedData.LTA(ibin).All = nanmean(obj.BinnedData.LTA(ibin).All, 3);
					% 
					% 	siITI
					% 
					obj.BinnedData.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					obj.BinParams.Legend_s.siITI{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
					obj.BinParams.s(ibin).siITI_Min = binEdges(ibin)/1000;
					obj.BinParams.s(ibin).siITI_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.s(ibin).siITI_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.BinParams.binEdges_CLTA = binEdges;
                obj.BinParams.binEdges_siITI = binEdges;
                obj.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.nbins_CLTA = nbins;
                obj.BinParams.nbins_siITI = nbins;

			% --------------------------------------------------------------------------------------------------
			% 	HANDLE THE STIMULATION CASES ----------- INCOMPLETE 9/10/18
			% --------------------------------------------------------------------------------------------------
			elseif strcmpi(obj.Mode, 'Times') && obj.Stim.stimobj
				warning('Stimulation case not well debugged 9/10/18')
				% 
				% 	The only differences are we are going to apply a mask for the times for stim/unstim case.
				% 	We will end up with 2 bin categories now: stim and unstim
				% 		NOTE: siITI NOT HANDLED SEPARATELY!!!!!!
				% 
				obj.updateLog(['Attempting to bin STIM and PHOT data with even blocks of time... (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Divide the total trial time into equal sized bins of time
				% 		e.g., 17 bins = [0:1s], [1s:2s], ... , [16s:17s]
				% 	We will allow the last time bin to be smaller than the rest
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				nbins = obj.BinParams.ogBins;
				time_per_bin_ms = obj.iv.total_time_ / nbins;
				binEdges = 1:time_per_bin_ms:obj.iv.total_time_;
                % Make sure we have the right number of bins...
                if length(binEdges) < nbins + 1
                    binEdges(end+1) = obj.iv.total_time_;
                end
				obj.updateLog(['nbins: ' num2str(nbins) ' || time per bin (ms): ' num2str(time_per_bin_ms) ' || binEdges: ' mat2str(binEdges) ' \n']);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                all_fl_wrtc_ms = nansum(all_fl_wrtc_ms, 3); 
                % 
                % 	*** Make sure we have a stim and unstim mask:
                % 
                all_fl_wrtc_ms_stim = all_fl_wrtc_ms;
                all_fl_wrtc_ms_stim(obj.ChR2.stim_struct.nostim_trials) = 0;
                % 
                all_fl_wrtc_ms_unstim = all_fl_wrtc_ms;
                all_fl_wrtc_ms_unstim(obj.ChR2.stim_struct.stimTrials) = 0;
				% 
				% 	Find the lick times in ms wrt cue for each trial -- STIM CASE
				% 
				for ibin = 1:nbins
					obj.updateLog(['Processing STIM bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					ll = find(all_fl_wrtc_ms_stim >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms_stim < binEdges(ibin + 1));
					trials_in_each_bin(ibin).stim.CTA =  ll(ismember(ll, ul));
					trials_in_each_bin(ibin).stim.LTA = trials_in_each_bin(ibin).stim.CTA;
					ll = find(obj.Plot.siITI.Lick.ms.wrtLastLick >= binEdges(ibin));
					ul = find(obj.Plot.siITI.Lick.ms.wrtLastLick < binEdges(ibin + 1));
					trials_in_each_bin(ibin).siITI = ll(ismember(ll, ul));
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.stim.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).stim.CTA, :), 1);
					obj.BinnedData.stim.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).stim.CTA,:), 1); 
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.stim.LTA(ibin).All = cat(3, obj.BinnedData.stim.LTA(ibin).rxn, obj.BinnedData.stim.LTA(ibin).early, obj.BinnedData.stim.LTA(ibin).rew, obj.BinnedData.stim.LTA(ibin).ITI);
					obj.BinnedData.stim.LTA(ibin).All = nanmean(obj.BinnedData.stim.LTA(ibin).All, 3);
					% 
					% 	siITI
					% 
					obj.BinnedData.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.stim.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					obj.BinParams.Legend_s.siITI{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.stim.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.BinParams.stim.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.stim.s(ibin).CLTA_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
					obj.BinParams.s(ibin).siITI_Min = binEdges(ibin)/1000;
					obj.BinParams.s(ibin).siITI_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.s(ibin).siITI_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
                end
                obj.BinParams.stim.binEdges_CLTA = binEdges;
                obj.BinParams.binEdges_siITI = binEdges;
                obj.BinParams.stim.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.stim.nbins_CLTA = nbins;
                obj.BinParams.nbins_siITI = nbins;
				% 
				% 	Find the lick times in ms wrt cue for each trial -- NO STIM CASE
				% 
				for ibin = 1:nbins
					obj.updateLog(['Processing NO-STIM bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					ll = find(all_fl_wrtc_ms_unstim >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms_unstim < binEdges(ibin + 1));
					trials_in_each_bin(ibin).unstim.CTA =  ll(ismember(ll, ul));
					trials_in_each_bin(ibin).unstim.LTA = trials_in_each_bin(ibin).unstim.CTA;
					ll = find(obj.Plot.siITI.Lick.ms.wrtLastLick >= binEdges(ibin));
					ul = find(obj.Plot.siITI.Lick.ms.wrtLastLick < binEdges(ibin + 1));
					trials_in_each_bin(ibin).siITI = ll(ismember(ll, ul));
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.unstim.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).unstim.CTA, :), 1);
					obj.BinnedData.unstim.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).unstim.CTA,:), 1); 
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.unstim.LTA(ibin).All = cat(3, obj.BinnedData.unstim.LTA(ibin).rxn, obj.BinnedData.unstim.LTA(ibin).early, obj.BinnedData.unstim.LTA(ibin).rew, obj.BinnedData.unstim.LTA(ibin).ITI);
					obj.BinnedData.unstim.LTA(ibin).All = nanmean(obj.BinnedData.unstim.LTA(ibin).All, 3);
					% 
					% 	siITI
					% 
					% obj.BinnedData.unstim.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).unstim.siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.unstim.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					obj.BinParams.unstim.Legend_s.siITI{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.unstim.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.BinParams.unstim.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.unstim.s(ibin).CLTA_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
					% obj.BinParams.unstim.s(ibin).siITI_Min = binEdges(ibin)/1000;
					% obj.BinParams.unstim.s(ibin).siITI_Max = binEdges(ibin + 1)/1000;
					% obj.BinParams.unstim.s(ibin).siITI_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
                end
                obj.BinParams.unstim.binEdges_CLTA = binEdges;
                % obj.BinParams.unstim.binEdges_siITI = binEdges;
                obj.BinParams.unstim.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.unstim.nbins_CLTA = nbins;
                % obj.BinParams.unstim.nbins_siITI = nbins;

			%-----------------------------------------------------------------
			%					Stimulated case for TRIALS -- last modified 11/5/18
			%-----------------------------------------------------------------
			elseif strcmpi(obj.Mode, 'Trials') && obj.Stim.stimobj
				obj.updateLog(['Attempting to bin STIM and PHOT data with even numbers of trials... (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Divide the total number of trials into equal sized bins of trials
				% 		e.g., 5000 trials = [1:500], [501:1000], ... , [4501:5000]
				% 	We will allow the last trial bin to be smaller than the rest
				% 		*** IN THIS CASE, nbins will refer to number of TRIALS per bin
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				% 	*** FOR STIM/NO STIM, we just do separately....
				% 		NOTE: siITI NOT HANDLED!!!!!!!!!
				% ----------------------------------------
				% 	*** STIM
				% ----------------------------------------
				warning('Stim case not fully vetted. Last modified 11/5/18. ITI NOT HANDLED!!!!!!')
				ntrials_per_bin = obj.BinParams.ogBins;
				if strcmp(obj.BinParams.ogBins, 'all')
					nbins_CLTA = 1;
					nbins_siITI = 1;
					ntrials_per_bin_CLTA = length(obj.ChR2.stim_struct.stimTrials);
					ntrials_per_bin_siITI = obj.iv.num_si_ITI_licks; % note, may want to look at stim/unstim separately in future ********
					binEdges_CLTA = [1,ntrials_per_bin_CLTA];
					binEdges_siITI = [1,obj.iv.num_si_ITI_licks];
				elseif obj.BinParams.ogBins == 1
					%  The last bin will have fewer trials
					nbins_CLTA = ceil(length(obj.ChR2.stim_struct.stimTrials)/obj.BinParams.ogBins);
					nbins_siITI = ceil(obj.iv.num_si_ITI_licks/obj.BinParams.ogBins);
					ntrials_per_bin_CLTA = ntrials_per_bin;
					ntrials_per_bin_siITI = ntrials_per_bin;
					binEdges_CLTA = 1:ntrials_per_bin_CLTA:length(obj.ChR2.stim_struct.stimTrials)+1;
					if binEdges_CLTA(end) ~= length(obj.ChR2.stim_struct.stimTrials)
						binEdges_CLTA(end+1) = length(obj.ChR2.stim_struct.stimTrials);
					end
					binEdges_siITI = 1:ntrials_per_bin_CLTA:obj.iv.num_si_ITI_licks+1;
					if binEdges_siITI(end) ~= obj.iv.num_si_ITI_licks
						binEdges_siITI(end+1) = obj.iv.num_si_ITI_licks;
					end	
				else
					%  The last bin will have fewer trials
					nbins_CLTA = ceil(length(obj.ChR2.stim_struct.stimTrials)/obj.BinParams.ogBins);
					nbins_siITI = ceil(obj.iv.num_si_ITI_licks/obj.BinParams.ogBins);
					ntrials_per_bin_CLTA = ntrials_per_bin;
					ntrials_per_bin_siITI = ntrials_per_bin;
					binEdges_CLTA = 1:ntrials_per_bin_CLTA:length(obj.ChR2.stim_struct.stimTrials);
					if binEdges_CLTA(end) ~= length(obj.ChR2.stim_struct.stimTrials)
						binEdges_CLTA(end+1) = length(obj.ChR2.stim_struct.stimTrials);
					end
					binEdges_siITI = 1:ntrials_per_bin_CLTA:obj.iv.num_si_ITI_licks;
					if binEdges_siITI(end) ~= obj.iv.num_si_ITI_licks
						binEdges_siITI(end+1) = obj.iv.num_si_ITI_licks;
					end
				end

				obj.updateLog(['STIM CASE: nbins-CLTA: ' num2str(nbins_CLTA) '|| nbins-siITI: ' num2str(nbins_siITI) ' || # trials per bin (ms): ' num2str(ntrials_per_bin) ' || binEdges-CLTA: ' mat2str(binEdges_CLTA) ' || binEdges-siITI: ' mat2str(binEdges_siITI) ' \n']);
				% 
				% 	Next, we will need to sort the lick times
				% 
                % warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                all_fl_wrtc_ms_stim = nansum(all_fl_wrtc_ms, 3); 
                all_fl_wrtc_ms_stim(obj.ChR2.stim_struct.nostim_trials) = 0; 
				all_fl_wrtc_ms_stim = [all_fl_wrtc_ms_stim; 1:obj.iv.num_trials];
				sorted_lt_wrtc_ms_stim = sortrows(all_fl_wrtc_ms_stim',1)';

				all_siITI_wrtLastLick_ms = [obj.Plot.siITI.Lick.ms.wrtLastLick' ; 1:obj.iv.num_si_ITI_licks];
				sorted_siITI_wrtLastLick_ms = sortrows(all_siITI_wrtLastLick_ms',1)';
				obj.updateLog(['Lick times sorted. (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Now binning is simple...
				% 		CTA 				LTA 				siITI
				% 1| 	1:500 sorted_lt	 	1:500 sorted_lt		1:500 sorted_siITI
				% 2| 	501:1000 sorted_lt	501:1000 sorted_lt	501:1000 sorted_siITI
				% ...
				% 
				trials_in_each_bin_stim = {};
                % trials_in_each_bin(1:nbins).CTA = []; 
                % trials_in_each_bin(1:nbins).LTA = [];
                % trials_in_each_bin(1:nbins).siITI = [];
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				for ibin = 1:nbins_CLTA
					if abs(rem(nbins_CLTA*.10, ibin)) < 0.5
						obj.updateLog(['Processing STIM CTLA bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					end
					trials_in_each_bin(ibin).stim.CTA = sorted_lt_wrtc_ms_stim(2, binEdges_CLTA(ibin):binEdges_CLTA(ibin+1)-1);
					trials_in_each_bin(ibin).stim.LTA = trials_in_each_bin(ibin).stim.CTA;
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.stim.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).stim.CTA, :), 1);
					obj.BinnedData.stim.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).stim.CTA, :), 1); 
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.stim.LTA(ibin).All = cat(3, obj.BinnedData.stim.LTA(ibin).rxn, obj.BinnedData.stim.LTA(ibin).early, obj.BinnedData.stim.LTA(ibin).rew, obj.BinnedData.stim.LTA(ibin).ITI);
					obj.BinnedData.stim.LTA(ibin).All = nanmean(obj.BinnedData.stim.LTA(ibin).All, 3); 
	                % 
					% 	Append the legend
					% 
					obj.BinParams.stim.Legend_s.CLTA{ibin} = [num2str(round(sorted_lt_wrtc_ms_stim(1, binEdges_CLTA(ibin))/1000,3)), 's - ', num2str(round(sorted_lt_wrtc_ms_stim(1, binEdges_CLTA(ibin+1)-1)/1000,3)), 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.stim.s(ibin).CLTA_Min = sorted_lt_wrtc_ms_stim(1, binEdges_CLTA(ibin))/1000;
					obj.BinParams.stim.s(ibin).CLTA_Max = sorted_lt_wrtc_ms_stim(1, binEdges_CLTA(ibin+1)-1)/1000;
					obj.BinParams.stim.s(ibin).CLTA_Center = (obj.BinParams.stim.s(ibin).CLTA_Min + (obj.BinParams.stim.s(ibin).CLTA_Max - obj.BinParams.stim.s(ibin).CLTA_Min)/2);
					% 
                end
				for ibin = 1:nbins_siITI
					if abs(rem(nbins_siITI*.10, ibin)) < 0.5
						obj.updateLog(['Processing siITI bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					end
					% 
					% 	siITI
					% 
					trials_in_each_bin(ibin).siITI = sorted_siITI_wrtLastLick_ms(2, binEdges_siITI(ibin):binEdges_siITI(ibin+1)-1);
					obj.BinnedData.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.Legend_s.siITI{ibin} = [num2str(round(sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin))/1000,3)) 's - ' num2str(round(sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin+1)-1)/1000,3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.s(ibin).siITI_Min = sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin))/1000;
					obj.BinParams.s(ibin).siITI_Max = sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin+1)-1)/1000;
					obj.BinParams.s(ibin).siITI_Center = (obj.BinParams.s(ibin).siITI_Min + (obj.BinParams.s(ibin).siITI_Max - obj.BinParams.s(ibin).siITI_Min)/2);
					%
				end
                obj.BinParams.stim.binEdges_CLTA = binEdges_CLTA;
                obj.BinParams.stim.binEdges_siITI = binEdges_siITI;
                obj.BinParams.stim.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.stim.ntrials_per_bin_CLTA = ntrials_per_bin_CLTA;
				obj.BinParams.stim.ntrials_per_bin_siITI = ntrials_per_bin_siITI;
				obj.BinParams.stim.nbins_CLTA = nbins_CLTA;
                obj.BinParams.stim.nbins_siITI = nbins_siITI;
                % ----------------------------------------
				% 	*** UNSTIM
				% ----------------------------------------
				ntrials_per_bin = obj.BinParams.ogBins;
				if strcmp(obj.BinParams.ogBins, 'all')
					nbins_CLTA = 1;
					% nbins_siITI = 1;
					ntrials_per_bin_CLTA = length(obj.ChR2.stim_struct.nostim_trials);
					% ntrials_per_bin_siITI = obj.iv.num_si_ITI_licks; % note, may want to look at stim/unstim separately in future ********
					binEdges_CLTA = [1,ntrials_per_bin_CLTA];
					% binEdges_siITI = [1,obj.iv.num_si_ITI_licks];
				else
					%  The last bin will have fewer trials
					nbins_CLTA = ceil(length(obj.ChR2.stim_struct.nostim_trials)/obj.BinParams.ogBins);
					nbins_siITI = ceil(obj.iv.num_si_ITI_licks/obj.BinParams.ogBins);
					ntrials_per_bin_CLTA = ntrials_per_bin;
					ntrials_per_bin_siITI = ntrials_per_bin;
					binEdges_CLTA = 1:ntrials_per_bin_CLTA:length(obj.ChR2.stim_struct.nostim_trials);
					if binEdges_CLTA(end) ~= length(obj.ChR2.stim_struct.nostim_trials)
						binEdges_CLTA(end+1) = length(obj.ChR2.stim_struct.nostim_trials);
					end
					% binEdges_siITI = 1:ntrials_per_bin_CLTA:obj.iv.num_si_ITI_licks;
					% if binEdges_siITI(end) ~= obj.iv.num_si_ITI_licks
					% 	binEdges_siITI(end+1) = obj.iv.num_si_ITI_licks;
					% end
				end

				obj.updateLog(['NO-STIM CASE: nbins-CLTA: ' num2str(nbins_CLTA) '|| nbins-siITI: ' num2str(nbins_siITI) ' || # trials per bin (ms): ' num2str(ntrials_per_bin) ' || binEdges-CLTA: ' mat2str(binEdges_CLTA) ' || binEdges-siITI: ' mat2str(binEdges_siITI) ' \n']);
				% 
				% 	Next, we will need to sort the lick times
				% 
                all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                all_fl_wrtc_ms_unstim = nansum(all_fl_wrtc_ms, 3); 
                all_fl_wrtc_ms_unstim(obj.ChR2.stim_struct.stimTrials) = 0; 
				all_fl_wrtc_ms_unstim = [all_fl_wrtc_ms_unstim; 1:obj.iv.num_trials];
				sorted_lt_wrtc_ms_unstim = sortrows(all_fl_wrtc_ms_unstim',1)';

				% all_siITI_wrtLastLick_ms = [obj.Plot.siITI.Lick.ms.wrtLastLick' ; 1:obj.iv.num_si_ITI_licks];
				% sorted_siITI_wrtLastLick_ms = sortrows(all_siITI_wrtLastLick_ms',1)';
				obj.updateLog(['Lick times sorted. (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	Now binning is simple...
				% 		CTA 				LTA 				siITI
				% 1| 	1:500 sorted_lt	 	1:500 sorted_lt		1:500 sorted_siITI
				% 2| 	501:1000 sorted_lt	501:1000 sorted_lt	501:1000 sorted_siITI
				% ...
				% 
				trials_in_each_bin_unstim = {};
                % trials_in_each_bin(1:nbins).CTA = []; 
                % trials_in_each_bin(1:nbins).LTA = [];
                % trials_in_each_bin(1:nbins).siITI = [];
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				for ibin = 1:nbins_CLTA
					obj.updateLog(['Processing NO-STIM CTLA bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					trials_in_each_bin(ibin).unstim.CTA = sorted_lt_wrtc_ms_unstim(2, binEdges_CLTA(ibin):binEdges_CLTA(ibin+1)-1);
					trials_in_each_bin(ibin).unstim.LTA = trials_in_each_bin(ibin).unstim.CTA;
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.unstim.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).unstim.CTA, :), 1);
					obj.BinnedData.unstim.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).unstim.CTA, :), 1); 
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.unstim.LTA(ibin).All = cat(3, obj.BinnedData.unstim.LTA(ibin).rxn, obj.BinnedData.unstim.LTA(ibin).early, obj.BinnedData.unstim.LTA(ibin).rew, obj.BinnedData.unstim.LTA(ibin).ITI);
					obj.BinnedData.unstim.LTA(ibin).All = nanmean(obj.BinnedData.unstim.LTA(ibin).All, 3); 
	                % 
					% 	Append the legend
					% 
					obj.BinParams.unstim.Legend_s.CLTA{ibin} = [num2str(round(sorted_lt_wrtc_ms_unstim(1, binEdges_CLTA(ibin))/1000,3)), 's - ', num2str(round(sorted_lt_wrtc_ms_unstim(1, binEdges_CLTA(ibin+1)-1)/1000,3)), 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.unstim.s(ibin).CLTA_Min = sorted_lt_wrtc_ms_unstim(1, binEdges_CLTA(ibin))/1000;
					obj.BinParams.unstim.s(ibin).CLTA_Max = sorted_lt_wrtc_ms_unstim(1, binEdges_CLTA(ibin+1)-1)/1000;
					obj.BinParams.unstim.s(ibin).CLTA_Center = (obj.BinParams.unstim.s(ibin).CLTA_Min + (obj.BinParams.unstim.s(ibin).CLTA_Max - obj.BinParams.unstim.s(ibin).CLTA_Min)/2);
					% 
                end
				% for ibin = 1:nbins_siITI
				% 	obj.updateLog(['Processing siITI bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
				% 	% 
				% 	% 	siITI
				% 	% 
				% 	trials_in_each_bin(ibin).siITI = sorted_siITI_wrtLastLick_ms(2, binEdges_siITI(ibin):binEdges_siITI(ibin+1)-1);
				% 	obj.BinnedData.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).siITI, :), 1);
				% 	% 
				% 	% 	Append the legend
				% 	% 
				% 	obj.BinParams.Legend_s.siITI{ibin} = [num2str(round(sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin))/1000,3)) 's - ' num2str(round(sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin+1)-1)/1000,3)) 's'];
				% 	% 
				% 	% 	Get Bin Time Centers and Ranges
				% 	% 
				% 	obj.BinParams.s(ibin).siITI_Min = sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin))/1000;
				% 	obj.BinParams.s(ibin).siITI_Max = sorted_siITI_wrtLastLick_ms(1, binEdges_siITI(ibin+1)-1)/1000;
				% 	obj.BinParams.s(ibin).siITI_Center = (obj.BinParams.s(ibin).siITI_Min + (obj.BinParams.s(ibin).siITI_Max - obj.BinParams.s(ibin).siITI_Min)/2)/1000;
				% 	%
				% end
                obj.BinParams.unstim.binEdges_CLTA = binEdges_CLTA;
                % obj.BinParams.unstim.binEdges_siITI = binEdges_siITI;
                obj.BinParams.unstim.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.unstim.ntrials_per_bin_CLTA = ntrials_per_bin_CLTA;
				obj.BinParams.unstim.ntrials_per_bin_siITI = ntrials_per_bin_siITI;
				obj.BinParams.unstim.nbins_CLTA = nbins_CLTA;
                % obj.BinParams.unstim.nbins_siITI = nbins_siITI;
			
            % -------------------------------------------------------------------------------------- 					
            % 					Stimulated case for OUTCOMES - modified 11/5/18
            % --------------------------------------------------------------------------------------
			elseif strcmpi(obj.Mode, 'Outcome') && obj.Stim.stimobj
				warning('Stim case not fully vetted. Last modified 11/5/18. ITI NOT HANDLED!!!!!!')
				obj.updateLog(['Attempting to bin data by outcome... (' datestr(now,'HH:MM AM') ') \n']);
				% 
				% 	There will be only 6 bins - one for each category and 2 bufferzones
				% 
				disp('Note that the reward boundary (3333ms) is not well defined, so bin 4 is 3330-3332 to avoid overlap of rew and unrewarded lost in sampling...')
				nbins = obj.BinParams.ogBins;
				rxnmax = data.init_variables.time_parameters.ms.rxn_time_ms;
				rxnbuffer = 700;
				earlymax = 3330;
				rewbuffer = 3333;
				rewardmax = data.init_variables.time_parameters.ms.ITI_time_ms+1;
				itimax = data.init_variables.time_parameters.ms.total_time_ms+1;
				binEdges = [1, rxnmax, rxnbuffer, earlymax, rewbuffer, rewardmax, itimax];
                % Make sure we have the right number of bins...
				obj.updateLog(['nbins: ' num2str(nbins) ' || binEdges: ' mat2str(binEdges) ' \n']);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                all_fl_wrtc_ms = nansum(all_fl_wrtc_ms, 3); 
                % 
                % 	*** Make sure we have a stim and unstim mask:
                % 
                all_fl_wrtc_ms_stim = all_fl_wrtc_ms;
                all_fl_wrtc_ms_stim(obj.ChR2.stim_struct.nostim_trials) = 0;
                % 
                all_fl_wrtc_ms_unstim = all_fl_wrtc_ms;
                all_fl_wrtc_ms_unstim(obj.ChR2.stim_struct.stimTrials) = 0;
				% 
				% 	Find the lick times in ms wrt cue for each trial -- STIM CASE
				% 
				for ibin = 1:nbins
					obj.updateLog(['Processing STIM bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					ll = find(all_fl_wrtc_ms_stim >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms_stim < binEdges(ibin + 1));
					trials_in_each_bin(ibin).stim.CTA =  ll(ismember(ll, ul));
					trials_in_each_bin(ibin).stim.LTA = trials_in_each_bin(ibin).stim.CTA;
					ll = find(obj.Plot.siITI.Lick.ms.wrtLastLick >= binEdges(ibin));
					ul = find(obj.Plot.siITI.Lick.ms.wrtLastLick < binEdges(ibin + 1));
					trials_in_each_bin(ibin).siITI = ll(ismember(ll, ul));
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.stim.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).stim.CTA, :), 1);
					obj.BinnedData.stim.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).stim.CTA,:), 1); 
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).stim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.stim.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).stim.LTA, :), 1);
					else
						obj.BinnedData.stim.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.stim.LTA(ibin).All = cat(3, obj.BinnedData.stim.LTA(ibin).rxn, obj.BinnedData.stim.LTA(ibin).early, obj.BinnedData.stim.LTA(ibin).rew, obj.BinnedData.stim.LTA(ibin).ITI);
					obj.BinnedData.stim.LTA(ibin).All = nanmean(obj.BinnedData.stim.LTA(ibin).All, 3);
					% 
					% 	siITI
					% 
					obj.BinnedData.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.stim.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					obj.BinParams.Legend_s.siITI{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.stim.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.BinParams.stim.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.stim.s(ibin).CLTA_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
					obj.BinParams.s(ibin).siITI_Min = binEdges(ibin)/1000;
					obj.BinParams.s(ibin).siITI_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.s(ibin).siITI_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
                end
                obj.BinParams.stim.binEdges_CLTA = binEdges;
                obj.BinParams.binEdges_siITI = binEdges;
                obj.BinParams.stim.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.stim.nbins_CLTA = nbins;
                obj.BinParams.nbins_siITI = nbins;
				% 
				% 	Find the lick times in ms wrt cue for each trial -- NO STIM CASE
				% 
				for ibin = 1:nbins
					obj.updateLog(['Processing NO-STIM bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ') \n']);
					ll = find(all_fl_wrtc_ms_unstim >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms_unstim < binEdges(ibin + 1));
					trials_in_each_bin(ibin).unstim.CTA =  ll(ismember(ll, ul));
					trials_in_each_bin(ibin).unstim.LTA = trials_in_each_bin(ibin).unstim.CTA;
					ll = find(obj.Plot.siITI.Lick.ms.wrtLastLick >= binEdges(ibin));
					ul = find(obj.Plot.siITI.Lick.ms.wrtLastLick < binEdges(ibin + 1));
					trials_in_each_bin(ibin).siITI = ll(ismember(ll, ul));
					% 
					% 	Average across trials in each bin
					%
					obj.BinnedData.unstim.CTA{ibin} = nanmean(data.signal_ex_values_by_trial(trials_in_each_bin(ibin).unstim.CTA, :), 1);
					obj.BinnedData.unstim.CTAtoLick{ibin} = nanmean(data.signal_ex_values_up_to_lick(trials_in_each_bin(ibin).unstim.CTA,:), 1); 
					% 
					% 	For LTA, first check and see what category we are in...
					% 
					%  PAVLOVIAN
					if strcmp(obj.iv.exptype_, 'hyb')
						disp('PAV NOT IMPLEMENTED - need to gather pavlovian f_ex_licks earlier in obj file to use')
					end
					%  RXN
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_rxn > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).rxn = nanmean(data.LT_struct.rxn_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).rxn = nan(1, obj.Plot.LTA.size);
					end
					%  EARLY
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_no_rew > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).early = nanmean(data.LT_struct.early_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).early = nan(1, obj.Plot.LTA.size);
					end
					%  REWARD
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_operant_rew > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).rew = nanmean(data.LT_struct.rew_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).rew = nan(1, obj.Plot.LTA.size);
					end
					%  ITI
					if sum(ismember([trials_in_each_bin(ibin).unstim.LTA], find(obj.Plot.wrtCTAArray.Lick.s.f_ex_lick_ITI > 0))) > 0
						obj.BinnedData.unstim.LTA(ibin).ITI = nanmean(data.LT_struct.ITI_LT_by_trial(trials_in_each_bin(ibin).unstim.LTA, :), 1);
					else
						obj.BinnedData.unstim.LTA(ibin).ITI = nan(1, obj.Plot.LTA.size);
					end
					% 
					% 	Finally, collect a binned ave LTA for all types (NOT INCLUDING PAV**)
					% 
					obj.BinnedData.unstim.LTA(ibin).All = cat(3, obj.BinnedData.unstim.LTA(ibin).rxn, obj.BinnedData.unstim.LTA(ibin).early, obj.BinnedData.unstim.LTA(ibin).rew, obj.BinnedData.unstim.LTA(ibin).ITI);
					obj.BinnedData.unstim.LTA(ibin).All = nanmean(obj.BinnedData.unstim.LTA(ibin).All, 3);
					% 
					% 	siITI
					% 
					% obj.BinnedData.unstim.siITI{ibin} = nanmean(data.lick_data_struct.LT_si_ITI_struct.by_trial.LT_si_ITI_by_trial(trials_in_each_bin(ibin).unstim.siITI, :), 1);
					% 
					% 	Append the legend
					% 
					obj.BinParams.unstim.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					obj.BinParams.unstim.Legend_s.siITI{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's'];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.BinParams.unstim.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.BinParams.unstim.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.BinParams.unstim.s(ibin).CLTA_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
					% obj.BinParams.unstim.s(ibin).siITI_Min = binEdges(ibin)/1000;
					% obj.BinParams.unstim.s(ibin).siITI_Max = binEdges(ibin + 1)/1000;
					% obj.BinParams.unstim.s(ibin).siITI_Center = (binEdges(ibin) + (binEdges(ibin+1) - binEdges(ibin))/2)/1000;
                end
                obj.BinParams.unstim.binEdges_CLTA = binEdges;
                % obj.BinParams.unstim.binEdges_siITI = binEdges;
                obj.BinParams.unstim.trials_in_each_bin = trials_in_each_bin;
                obj.BinParams.unstim.nbins_CLTA = nbins;
                % obj.BinParams.unstim.nbins_siITI = nbins;
            end
		end
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
	%-------------------------------------------------------
	%		Methods: Plot commands
	%-------------------------------------------------------

		% -----------------------------------------------------
		% 				PLOT
		%
		%	CTA/2l verified:	8/16/18
		% 	LTA verified:		8/16/18
		% 	siITI verified: 	8/16/18
		% 	stim/unstim?:		?		- note that must use Matlab's smoothing method because have nans in binned ave...
		% 						CTA2l especially may have errors in stim case 10/8/18
		% 	LTA2l				10/9/18
		% 	CLTA unverified...
		% 	CTA-CTA2l Overlay 	1/17/19
		% 	
		% -----------------------------------------------------
		function plot(obj, pType, bins, inset, smoothing, Order, useTS)
			warning('LineWidth changed here!')
			lw = 2;
			fontSz = 30;
			if ~isfield(obj.iv, 'correctedSamplingRate')
				warning('Sampling Rate Not Corrected! Collecting now... CAUTION WITH BINNED DATA IF FLAG PRESENT!')
				obj.correctSamplingRate();
			end
			if nargin < 7
				useTS = false;
			end
			if ~useTS && strcmp(obj.iv.setStyle, 'v3x-single session') 
				warning('PLOT SHOULD ONLY BE USED WITH BINNEDTS BECAUSE IS GETTING MAIN PLOT STUFF CONFUSED WITH TS - CHECK THIS OUT AND REMOVE POST-DEBUG!')
			end
			if nargin < 6
				Order = 'last-to-first';
			end
			if nargin < 5
				smoothing = obj.Plot.smooth_kernel;
				% 
				% Other options: 150, 0 for raw signal
			end
			if nargin < 4
				inset = false;
			end
			if nargin < 3
				bins = 'all';
			end
			bins0 = bins;
			% ------------------------------------------------------
			%   	Now plot that mofo -- photometry only case
			% ------------------------------------------------------
			if ~isstruct(obj.Stim) || ~obj.Stim.stimobj
				% 
				% 	Check for critical plot params
				% 
				if ~isfield(obj.Plot.wrtCue.Events.s, 'total_time_ms')
					warning('Total time in s not specified - extrapolating from obj.iv.total_time_...')
					obj.Plot.wrtCue.Events.s.total_time_ms = obj.iv.total_time_/1000;
				end
				% 
				%	Handle bin mode 
				% 
				if ischar(bins) && strcmpi(bins, 'all')
					if ~useTS
						if ~strcmpi(pType, 'siITI')
							bins = 1:obj.BinParams.nbins_CLTA;
						elseif strcmpi(pType, 'siITI')
							bins = 1:obj.BinParams.nbins_siITI;
						end
					else
						if ~strcmpi(pType, 'siITI')
							bins = 1:obj.ts.BinParams.nbins_CLTA;
						elseif strcmpi(pType, 'siITI')
							error('Not implemented for siITI in timeseries binning.')
						end
					end
				end
				% 
				% 	Handle ordering
				% 
				if strcmp(Order, 'first-to-last')
					disp('Plotting first-to-last bins')
					i_minus = false;
					i_first = bins(1);
					binrange = bins(2:end);
				else
					disp('Plotting last-to-first bins')
					i_minus = true;
					i_first = bins(end);
					binrange = flip(bins(1:end-1));
				end
				% 
				if ~inset
					f1 = figure;
		            C = linspecer(length(bins)); 
		            ax = axes('NextPlot','replacechildren', 'ColorOrder',C);
	            end
				if strcmpi(pType, 'CTA')
					if ~useTS
						BinnedData.CTA = obj.BinnedData.CTA;
						BinParams = obj.BinParams;
						xticks = obj.Plot.CTA.xticks.s;
					else
						BinnedData.CTA = obj.ts.BinnedData.CTA;
						BinParams = obj.ts.BinParams;
						xticks = obj.ts.Plot.CTA.xticks.s;
					end
					disp('~~~~~~~~~~~~~~Plotting CTA~~~~~~~~~~~~~~~~')
	                yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), BinnedData.CTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), BinnedData.CTA));
	                plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold on
					plot(xticks,obj.smooth(BinnedData.CTA{1, i_first},smoothing), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(xticks, obj.smooth(BinnedData.CTA{1, ibin},smoothing), 'linewidth', lw), end
						leg = BinParams.Legend_s.CLTA(binrange);
	                    leg2 = {BinParams.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
						legend(leg)
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
					else
						for ibin = binrange, plot(xticks, obj.smooth(BinnedData.CTA{1, ibin}, smoothing), 'linewidth', lw), end
						legend(horzcat({'cue'}, BinParams.Legend_s.CLTA{i_first}, BinParams.Legend_s.CLTA{binrange}))
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
					end
					
				% elseif strcmpi(pType, 'CTA2l')
				% 	disp('~~~~~~~~~~~~~~Plotting CTA up to first lick~~~~~~~~~~~~~~~~')
				% 	yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), obj.BinnedData.CTAtoLick));
				% 	yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), obj.BinnedData.CTAtoLick));
	   %              plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
				% 	hold on
	   %              plot(obj.Plot.CTA.xticks.s,obj.smooth(obj.BinnedData.CTAtoLick{1, i_first},smoothing))
				% 	if i_minus
				% 		for ibin = binrange, 
	   %                      plot(obj.Plot.CTA.xticks.s, obj.smooth(obj.BinnedData.CTAtoLick{1, ibin},smoothing)), 
	   %                  end
	   %                  leg = obj.BinParams.Legend_s.CLTA(binrange);
	   %                  leg2 = {obj.BinParams.Legend_s.CLTA{i_first}};
	   %                  leg = horzcat({'cue'}, leg2, leg);
	   %                  legend(leg)
				% 		xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
				% 		title(['CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
				% 		xlabel('Time wrt Cue (s)')
				% 		ylabel('dF/F')
				% 	else
				% 		for ibin = binrange, plot(obj.Plot.CTA.xticks.s, obj.smooth(obj.BinnedData.CTAtoLick{1, ibin}, smoothing)), end
				% 		legend(horzcat({'cue'}, obj.BinParams.Legend_s.CLTA{i_first}, obj.BinParams.Legend_s.CLTA{binrange}))
				% 		xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
				% 		title(['CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
				% 		xlabel('Time wrt Cue (s)')
				% 		ylabel('dF/F')
				% 	end
				elseif strcmpi(pType, 'CTA2l')
					if ~useTS
						BinnedData.CTA = obj.BinnedData.CTA;
						BinParams = obj.BinParams;
						xticks = obj.Plot.CTA.xticks.s;
					else
						BinnedData.CTA = obj.ts.BinnedData.CTA;
						BinParams = obj.ts.BinParams;
						xticks = obj.ts.Plot.CTA.xticks.s;
					end
					disp('~~~~~~~~~~~~~~Plotting CTA up to first lick~~~~~~~~~~~~~~~~')
					binMinPos = cellfun(@(x) find(xticks > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), BinnedData.CTA, 'UniformOutput', 0));
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), BinnedData.CTA(binrange)));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), BinnedData.CTA(binrange)));
                    if isempty(yMin)
                        yMin = nanmin(smoothedSets{1});
                        yMax = nanmax(smoothedSets{1});
                    end
	                plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					if inset
                        ts = cell2mat({BinParams.s(binrange).CLTA_Max});
		            	C = linspecer(numel(binrange)+1);
		            	set(gca, 'ColorOrder', C);
	            	end
					hold on
					if i_minus
						% binMinPos = flip(binMinPos);
		                plot(xticks(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, 
	                        plot(xticks(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), 
	                    end
						leg = BinParams.Legend_s.CLTA(binrange);
	                    leg2 = {BinParams.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
	                    legend(leg)
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['Stim+ CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					else
        				plot(xticks(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, plot(xticks(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), end
						legend(horzcat({'cue'}, BinParams.Legend_s.CLTA{i_first}, BinParams.Legend_s.CLTA{binrange}))
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['Stim+ CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					end	
					
				elseif strcmpi(pType, 'CTA/CTA2l')
					C = linspecer(length(bins)); 
		            set(ax, 'NextPlot','replacechildren', 'ColorOrder',C);
					if ~useTS
						BinnedData.CTA = obj.BinnedData.CTA;
						BinParams = obj.BinParams;
						xticks = obj.Plot.CTA.xticks.s;
					else
						BinnedData.CTA = obj.ts.BinnedData.CTA;
						BinParams = obj.ts.BinParams;
						xticks = obj.ts.Plot.CTA.xticks.s;
					end
					disp('~~~~~~~~~~~~~~Plotting CTA~~~~~~~~~~~~~~~~')
	                yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), BinnedData.CTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), BinnedData.CTA));
	                % plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold on
					plot(xticks,obj.smooth(BinnedData.CTA{1, i_first},smoothing))
					if i_minus
						for ibin = binrange, plot(xticks, obj.smooth(BinnedData.CTA{1, ibin},smoothing)), end
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
					else
						for ibin = binrange, plot(xticks, obj.smooth(BinnedData.CTA{1, ibin}, smoothing)), end
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
					end
					% 
					% 	Now overlay the CTA2l
					% 
					C = linspecer(length(bins)); 
		            set(ax,'ColorOrder',C-min(C));
					if ~useTS
						BinnedData.CTA = obj.BinnedData.CTA;
						BinParams = obj.BinParams;
						xticks = obj.Plot.CTA.xticks.s;
					else
						BinnedData.CTA = obj.ts.BinnedData.CTA;
						BinParams = obj.ts.BinParams;
						xticks = obj.ts.Plot.CTA.xticks.s;
					end
					disp('~~~~~~~~~~~~~~Overlaying CTA up to first lick~~~~~~~~~~~~~~~~')
					binMinPos = cellfun(@(x) find(xticks > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), BinnedData.CTA, 'UniformOutput', 0));
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), BinnedData.CTA(binrange)));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), BinnedData.CTA(binrange)));
	                plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold on
					if i_minus
						% binMinPos = flip(binMinPos);
		                plot(xticks(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, 
	                        plot(xticks(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), 
	                    end
						leg = BinParams.Legend_s.CLTA(binrange);
	                    leg2 = {BinParams.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
	                    legend(leg)
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					else
        				plot(xticks(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, plot(xticks(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), end
						legend(horzcat(BinParams.Legend_s.CLTA{binrange}, BinParams.Legend_s.CLTA{i_first}, {'cue'}))
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					end	

				elseif strcmpi(pType, 'LTA2l')
					if ~useTS
                        if isfield(obj.BinnedData.LTA, 'All')
    						BinnedData.LTA = {obj.BinnedData.LTA.All};
                        else
                            BinnedData.LTA = obj.ts.BinnedData.LTA;
                        end
						BinParams = obj.BinParams;
						xticks = obj.Plot.LTA.xticks.s;
					else
						BinnedData.LTA = obj.ts.BinnedData.LTA;
						BinParams = obj.ts.BinParams;
						xticks = obj.ts.Plot.LTA.xticks.s;
					end
					disp('~~~~~~~~~~~~~~Plotting LTA trimmed to cue~~~~~~~~~~~~~~~~')
					binMinPos = cellfun(@(x) find(xticks > -x, 1, 'first'), {BinParams.s.CLTA_Min}, 'UniformOutput', false);
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), BinnedData.LTA, 'UniformOutput', 0));
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), BinnedData.LTA(binrange)));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), BinnedData.LTA(binrange)));
	                if isempty(yMin)
                        yMin = nanmin(smoothedSets{1});
                        yMax = nanmax(smoothedSets{1});
                    end
                    plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'First Lick')
					hold on
					if i_minus
		                plot(xticks(binMinPos{i_first}:end), smoothedSets{1, i_first}(binMinPos{i_first}:end), 'linewidth', lw)
						for ibin = binrange, 
	                        plot(xticks(binMinPos{ibin}:end), smoothedSets{1, ibin}(binMinPos{ibin}:end), 'linewidth', lw), 
	                    end
						leg = BinParams.Legend_s.CLTA(binrange);
	                    leg2 = {BinParams.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
	                    legend(leg)
						xlim([xticks(min(cellfun(@(x) min(x), binMinPos))), 10])
						title(['LTA up to Cue: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Lick (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					else
        				plot(xticks(binMinPos{i_first}:end), smoothedSets{1, i_first}(binMinPos{i_first}:end), 'linewidth', lw)
						for ibin = binrange, plot(xticks(binMinPos{ibin}:end), smoothedSets{1, ibin}(binMinPos{ibin}:end), 'linewidth', lw), end
						legend(horzcat({'lick'}, BinParams.stim.Legend_s.CLTA{i_first}, BinParams.stim.Legend_s.CLTA{binrange}))
						xlim([min(binMinPos), 10])
						title(['LTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Lick (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					end	

				elseif strcmpi(pType, 'CLTA')
					if useTS, warning('Not tested yet for timeseries Case - must change things to xticks and obj.ts.BinnedData and obj.ts.BinParams'), end
					if ~useTS
                        if isfield(obj.BinnedData.LTA, 'All')
    						BinnedData.LTA = {obj.BinnedData.LTA.All};
                        else
                            BinnedData.LTA = obj.ts.BinnedData.LTA;
                        end
						BinnedData.CTA = obj.BinnedData.CTA;
						
						BinParams = obj.BinParams;

						xticks = {};
						xticks.CTA = obj.Plot.CTA.xticks.s;
						xticks.LTA = obj.Plot.LTA.xticks.s;

						lick_zero_pos = obj.Plot.lick_zero_position;
						cue_1_pos = obj.Plot.first_post_cue_position;
					else
						BinnedData.CTA = obj.ts.BinnedData.CTA;
						BinnedData.LTA = obj.ts.BinnedData.LTA;

						BinParams = obj.ts.BinParams;
						
						xticks.CTA = obj.ts.Plot.CTA.xticks.s;
						xticks.LTA = obj.ts.Plot.LTA.xticks.s;

						lick_zero_pos = find(obj.ts.Plot.LTA.xticks.s == 0);
						cue_1_pos = find(obj.ts.Plot.CTA.xticks.s == 0);
					end
					if strcmp(obj.iv.signaltype_, 'camera')
						if isfield(obj.iv, 'camoFs')
							FS = obj.iv.camoFs;
						else
							FS = 30;
						end
                        tick = 1/FS;
                        tailMultiplier = FS/1000;
                    elseif strcmp(obj.iv.signaltype_, 'photometry')
                        tick = 1/1000;
                        tailMultiplier = 1;
                    elseif strcmp(obj.iv.signaltype_, 'EMG') || strcmp(obj.iv.signaltype_, 'accelerometer')
                        tick = 1/2000;    
                        tailMultiplier = 2;
                    end

					CTA_cutoff_s = 0 + 0.5;
					CTA_cutoff_pos = cue_1_pos + 500*tailMultiplier; 
					LTA_trim_post_cue_pos = 700*tailMultiplier;
					LTA_trim_post_cue_s = 0.7;
					tail = 200;%1500;%5000;%1500; %0 
					warning('Tail change here!')
					centerORmin = 'min';
				

                   

					disp('~~~~~~~~~~~~~~Plotting CLTA~~~~~~~~~~~~~~~~')
	                yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), BinnedData.CTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), BinnedData.CTA));
	                plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold on
					plot(xticks.CTA(1:CTA_cutoff_pos),obj.smooth(BinnedData.CTA{1, i_first}(1:CTA_cutoff_pos),smoothing), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(xticks.CTA(1:CTA_cutoff_pos), obj.smooth(BinnedData.CTA{1, ibin}(1:CTA_cutoff_pos),smoothing), 'linewidth', lw), end
						leg = BinParams.Legend_s.CLTA(binrange);
	                    leg2 = {BinParams.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
						legend(leg)
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['C/LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
					else
						for ibin = binrange, plot(xticks.CTA(1:CTA_cutoff_pos), obj.smooth(BinnedData.CTA{1, ibin}(1:CTA_cutoff_pos), smoothing), 'linewidth', lw), end
						legend(horzcat({'cue'}, BinParams.Legend_s.CLTA{i_first}, BinParams.Legend_s.CLTA{binrange}))
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['C/LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
					end
					% 
					% 	Reset colors:
					% 
					if ~inset
			            C = linspecer(length(bins)); 
	            	end
	            	% 
	            	% 	LTA targets: (bin CENTERS)
	            	% 
	            	if strcmpi(centerORmin, 'min')
						binMinPos_LTA = cellfun(@(x) find(xticks.LTA > -(x), 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
						binMaxPos_CTA = cellfun(@(x) find(xticks.CTA > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
					elseif strcmpi(centerORmin, 'center')
						binMinPos_LTA = cellfun(@(x) find(xticks.LTA > -(x), 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
						binMaxPos_CTA = cellfun(@(x) find(xticks.CTA > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
					end
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), BinnedData.LTA, 'UniformOutput', 0));
					hold on		
					if strcmpi(centerORmin, 'min')
		                plot([BinParams.s(i_first).CLTA_Min,BinParams.s(i_first).CLTA_Min],[yMin, yMax], 'HandleVisibility','off');
		                for ibin = binrange
		                	plot([BinParams.s(ibin).CLTA_Min,BinParams.s(ibin).CLTA_Min],[yMin, yMax], 'HandleVisibility','off');
	                    end
                    elseif strcmpi(centerORmin, 'center')
                    	plot([BinParams.s(i_first).CLTA_Center,BinParams.s(i_first).CLTA_Center],[yMin, yMax], 'HandleVisibility','off');
		                for ibin = binrange
		                	plot([BinParams.s(ibin).CLTA_Center,BinParams.s(ibin).CLTA_Center],[yMin, yMax], 'HandleVisibility','off');
	                    end
                	end
					% 
					% 	Reset colors:
					% 
					if ~inset
			            C = linspecer(length(bins)); 
	            	end
	            	% 
	            	% 	LTA to BIN MIN -- so just plot up to lick and then have x-axis taken care of
	            	% 
            		CTA_s1 = LTA_trim_post_cue_s;
            		CTA_s2 = xticks.CTA(binMaxPos_CTA{i_first});
            		LTA_pos1 = binMinPos_LTA{i_first} + LTA_trim_post_cue_pos;
            		LTA_pos2 = lick_zero_pos+1;
                    if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
                        pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
                        if pad > 0
                            LTA_pos2 = LTA_pos2 + pad;
                        else
                            LTA_pos1 = LTA_pos1 - pad;

                        end
                    end
            		if LTA_pos2 - LTA_pos1 >0
		            	plot(CTA_s1:tick:CTA_s2+tail/1000, smoothedSets{1, i_first}(LTA_pos1:LTA_pos2+tail*tailMultiplier), 'linewidth', lw, 'HandleVisibility','off')
					else
						plot([], 'HandleVisibility','off')
					end
					for ibin = binrange
	            		CTA_s1 = LTA_trim_post_cue_s;
	            		CTA_s2 = xticks.CTA(binMaxPos_CTA{ibin});
	            		LTA_pos1 = binMinPos_LTA{ibin} + LTA_trim_post_cue_pos;
	            		LTA_pos2 = lick_zero_pos+1;
                        if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
                            pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
                            if pad > 0
                                LTA_pos2 = LTA_pos2 + pad;
                            else
                                LTA_pos1 = LTA_pos1 - pad;
                            end
                        end
	            		if LTA_pos2 - LTA_pos1 >0
			            	plot(CTA_s1:tick:CTA_s2+tail/1000, smoothedSets{1, ibin}(LTA_pos1:LTA_pos2+tail*tailMultiplier), 'LineWidth', lw, 'HandleVisibility','off')
						else
							plot([], 'HandleVisibility','off')
						end
                    end
					ylim([yMin, yMax])
					% 
					% 	Set for printing:
					% 
					set(gca, 'fontsize', 20)





	                
				elseif strcmpi(pType, 'LTA') 
					if ~useTS
                        if isfield(obj.BinnedData.LTA, 'All')
    						BinnedData.LTA = {obj.BinnedData.LTA.All};
                        else
                            BinnedData.LTA = obj.ts.BinnedData.LTA;
                        end
						BinParams = obj.BinParams;
						xticks = obj.Plot.LTA.xticks.s;
					else
						BinnedData.LTA = obj.ts.BinnedData.LTA;
						BinParams = obj.ts.BinParams;
						xticks = obj.ts.Plot.LTA.xticks.s;
					end
					
					disp('~~~~~~~~~~~~~~Plotting LTA~~~~~~~~~~~~~~~~')
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), BinnedData.LTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), BinnedData.LTA));
	                plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Lick')
                    if inset
                        ts = cell2mat({BinParams.s(binrange).CLTA_Max});
		            	C = linspecer(numel(binrange) - numel(ts(ts==0))+1);
		            	set(gca, 'ColorOrder', C);
	            	end
					hold on
					plot(xticks,obj.smooth(BinnedData.LTA{i_first},smoothing), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(xticks, obj.smooth(BinnedData.LTA{ibin},smoothing), 'linewidth', lw), end
						leg = BinParams.Legend_s.CLTA(binrange);
	                    leg2 = {BinParams.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
						legend(leg)
						xlim([-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(['LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt First Lick (s)')
						ylabel('dF/F')
					else
						for ibin = binrange, plot(xticks, obj.smooth(BinnedData.LTA{ibin}, smoothing), 'linewidth', lw), end
						leg = horzcat({'cue'}, BinParams.Legend_s.CLTA{i_first}, BinParams.Legend_s.CLTA{binrange});
	                    legend(leg)
						xlim([-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(['LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt First Lick (s)')
						ylabel('dF/F')
					end



					
				elseif strcmp(pType, 'siITI')
					disp('~~~~~~~~~~~~~~Plotting siITI LTA~~~~~~~~~~~~~~~~')
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing)), obj.BinnedData.siITI));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing)), obj.BinnedData.siITI));
	                plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Lick')
					hold on
					plot(obj.Plot.siITI.xticks.s,obj.smooth(obj.BinnedData.siITI{i_first},smoothing), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(obj.Plot.siITI.xticks.s, obj.smooth(obj.BinnedData.siITI{ibin},smoothing), 'linewidth', lw), end
						leg = obj.BinParams.Legend_s.siITI(binrange);
	                    leg2 = {obj.BinParams.Legend_s.siITI{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
						legend(leg)
						xlim([-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(['siITI: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Self-Initiated ITI Lick (s)')
						ylabel('dF/F')
					else
						for ibin = binrange, plot(obj.Plot.siITI.xticks.s, obj.smooth(obj.BinnedData.siITI{ibin}, smoothing), 'linewidth', lw), end
						leg = horzcat({'cue'}, obj.BinParams.Legend_s.siITI{i_first}, obj.BinParams.Legend_s.siITI{binrange});
	                    legend(leg)
						xlim([-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(['siITI: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Self-Initiated ITI Lick (s)')
						ylabel('dF/F')
					end
				end
			% -----------------------------------------------------------------------------------------------------------------------------------
			% 			Optogenetics and Photometry Case
			% -----------------------------------------------------------------------------------------------------------------------------------
			elseif obj.Stim.stimobj
				if useTS, error('Not Implemented for Stim Case'), end
				warning('Smoothing window extended by 100ms for moving averages...')
				smoothing = smoothing + 100;
				% 
				%	Handle bin mode 
				% 
				if ischar(bins) && strcmpi(bins, 'all')
					if ~strcmpi(pType, 'siITI')
						bins = 1:obj.BinParams.stim.nbins_CLTA;
					elseif strcmpi(pType, 'siITI')
						bins = 1:obj.BinParams.nbins_siITI; % no distinction for siITI
					end
				end
				% 
				% 	Handle ordering
				% 
				if strcmp(Order, 'first-to-last')
					disp('Plotting first-to-last bins')
					i_minus = false;
					i_first = bins(1);
					binrange = bins(2:end);
				else
					disp('Plotting last-to-first bins')
					i_minus = true;
					i_first = bins(end);
					binrange = flip(bins(1:end-1));
				end
				% 
				if ~inset
					f1 = figure;
		            C = linspecer(length(bins)); 
		            ax1 = subplot(1,2,1, 'NextPlot','replacechildren', 'ColorOrder',C);
		            ax2 = subplot(1,2,2, 'NextPlot','replacechildren', 'ColorOrder',C);
	            end
	            % 
				if strcmpi(pType, 'CTA')
					% ax1 = subplot(1,2,1);
					disp('~~~~~~~~~~~~~~Plotting CTA~~~~~~~~~~~~~~~~')
	                yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.stim.CTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.stim.CTA));
	                plot(ax1, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold(ax1, 'on');
					plot(ax1, obj.Plot.CTA.xticks.s,obj.smooth(obj.BinnedData.stim.CTA{1, i_first},smoothing, 'moving'), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(ax1, obj.Plot.CTA.xticks.s, obj.smooth(obj.BinnedData.stim.CTA{1, ibin},smoothing, 'moving'), 'linewidth', lw), end
						leg = obj.BinParams.stim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.stim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
						legend(leg)
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['Stim+ CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					else
						for ibin = binrange, plot(ax1, obj.Plot.CTA.xticks.s, obj.smooth(ax1, obj.BinnedData.stim.CTA{1, ibin}, smoothing, 'moving'), 'linewidth', lw), end
						legend(horzcat({'cue'}, obj.BinParams.stim.Legend_s.CLTA{i_first}, obj.BinParams.stim.Legend_s.CLTA{binrange}))
						xlim([-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(['Stim+ CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Cue (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					end	
				elseif strcmpi(pType, 'CTA2l')
					% ax1 = subplot(1,2,1);
					disp('~~~~~~~~~~~~~~Plotting CTA up to first lick~~~~~~~~~~~~~~~~')
					binMinPos = cellfun(@(x) find(obj.Plot.CTA.xticks.s > x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing, 'moving'), obj.BinnedData.stim.CTA, 'UniformOutput', 0));
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.stim.CTA(binrange)));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.stim.CTA(binrange)));
	                plot(ax1, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold(ax1, 'on');
					if i_minus
		                plot(ax1, obj.Plot.CTA.xticks.s(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, 
	                        plot(ax1, obj.Plot.CTA.xticks.s(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), 
	                    end
						leg = obj.BinParams.stim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.stim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
	                    legend(leg)
						xlim(ax1, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax1,['Stim+ CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt Cue (s)')
						ylabel(ax1, 'dF/F')
						ylim(ax1, [yMin, yMax])
					else
        				plot(ax1, obj.Plot.CTA.xticks.s(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, plot(ax1, obj.Plot.CTA.xticks.s(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), end
						legend(horzcat({'cue'}, obj.BinParams.stim.Legend_s.CLTA{i_first}, obj.BinParams.stim.Legend_s.CLTA{binrange}))
						xlim(ax1, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax1, ['Stim+ CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt Cue (s)')
						ylabel(ax1, 'dF/F')
						ylim(ax1, [yMin, yMax])
					end	
				elseif strcmpi(pType, 'LTA') 
					% ax1 = subplot(1,2,1);
					disp('~~~~~~~~~~~~~~Plotting LTA~~~~~~~~~~~~~~~~')
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.stim.LTA.All}));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.stim.LTA.All}));
	                plot(ax1, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Lick')
					hold(ax1, 'on');
					plot(ax1, obj.Plot.LTA.xticks.s,obj.smooth(obj.BinnedData.stim.LTA(i_first).All,smoothing, 'moving'), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(ax1, obj.Plot.LTA.xticks.s, obj.smooth(obj.BinnedData.stim.LTA(ibin).All,smoothing, 'moving'), 'linewidth', lw), end
						leg = obj.BinParams.stim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.stim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
						legend(ax1, leg)
						xlim(ax1, [-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(ax1, ['Stim+ LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt First Lick (s)')
						ylabel(ax1, 'dF/F')
						ylim(ax1, [yMin, yMax])
					else
						for ibin = binrange, plot(ax1, obj.Plot.LTA.xticks.s, obj.smooth(obj.BinnedData.stim.LTA(ibin).All, smoothing, 'moving'), 'linewidth', lw), end
						leg = horzcat({'cue'}, obj.BinParams.stim.Legend_s.CLTA{i_first}, obj.BinParams.stim.Legend_s.CLTA{binrange});
	                    legend(ax1, leg)
						xlim(ax1, [-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(ax1, ['Stim+ LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt First Lick (s)')
						ylabel(ax1, 'dF/F')
						ylim(ax1, [yMin, yMax])
					end
				elseif strcmpi(pType, 'LTA2l')
					% ax1 = subplot(1,2,1);
					disp('~~~~~~~~~~~~~~Plotting LTA trimmed to cue~~~~~~~~~~~~~~~~')
					binMinPos = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), {obj.BinParams.stim.s.CLTA_Min}, 'UniformOutput', false);
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing, 'moving'), {obj.BinnedData.stim.LTA.All}, 'UniformOutput', 0));
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.stim.LTA(binrange).All}));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.stim.LTA(binrange).All}));
	                plot(ax1, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'First Lick')
					hold(ax1, 'on');
					if i_minus
		                plot(ax1, obj.Plot.LTA.xticks.s(binMinPos{i_first}:end), smoothedSets{1, i_first}(binMinPos{i_first}:end), 'linewidth', lw)
						for ibin = binrange, 
	                        plot(ax1, obj.Plot.LTA.xticks.s(binMinPos{ibin}:end), smoothedSets{1, ibin}(binMinPos{ibin}:end), 'linewidth', lw), 
	                    end
						leg = obj.BinParams.stim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.stim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
	                    legend(ax1, leg)
						xlim(ax1, [obj.Plot.LTA.xticks.s(min(cellfun(@(x) min(x), binMinPos))), 10])
						title(ax1, ['LTA+stim up to Cue: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt Lick (s)')
						ylabel(ax1, 'dF/F')
						ylim(ax1, [yMin, yMax])
					else
        				plot(ax1, obj.Plot.CTA.xticks.s(binMinPos{i_first}:end), smoothedSets{1, i_first}(binMinPos{i_first}:end), 'linewidth', lw)
						for ibin = binrange, plot(ax1, obj.Plot.CTA.xticks.s(binMinPos{ibin}:end), smoothedSets{1, ibin}(binMinPos{ibin}:end), 'linewidth', lw), end
						legend(ax1, horzcat({'lick'}, obj.BinParams.stim.Legend_s.CLTA{i_first}, obj.BinParams.stim.Legend_s.CLTA{binrange}))
						xlim(ax1, [min(binMinPos), 10])
						title(ax1, ['LTA+stim up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt Lick (s)')
						ylabel(ax1, 'dF/F')
						ylim(ax1, [yMin, yMax])
					end	
				elseif strcmpi(pType, 'CLTA')
					% ax1 = subplot(1,2,1);
					CTA_cutoff_s = 0 + 0.5;
					CTA_cutoff_pos = obj.Plot.first_post_cue_position + 500; 
					LTA_trim_post_cue_pos = 700;
					LTA_trim_post_cue_s = 0.7;
					tail = 1500;%1500;
					centerORmin = 'center';


					disp('~~~~~~~~~~~~~~Plotting CLTA~~~~~~~~~~~~~~~~')
	                yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.stim.CTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.stim.CTA));
	                plot(ax1, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold(ax1, 'on')
					plot(ax1, obj.Plot.CTA.xticks.s(1:CTA_cutoff_pos),obj.smooth(obj.BinnedData.stim.CTA{1, i_first}(1:CTA_cutoff_pos),smoothing, 'moving'), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(ax1, obj.Plot.CTA.xticks.s(1:CTA_cutoff_pos), obj.smooth(obj.BinnedData.stim.CTA{1, ibin}(1:CTA_cutoff_pos),smoothing, 'moving'), 'linewidth', lw), end
						leg = obj.BinParams.stim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.stim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
						legend(ax1, leg)
						xlim(ax1, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax1, ['C/LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt Cue (s)')
						ylabel(ax1, 'dF/F')
					else
						for ibin = binrange, plot(ax1, obj.Plot.CTA.xticks.s(1:CTA_cutoff_pos), obj.smooth(obj.BinnedData.stim.CTA{1, ibin}(1:CTA_cutoff_pos), smoothing, 'moving'), 'linewidth', lw), end
						legend(horzcat({'cue'}, obj.BinParams.stim.Legend_s.CLTA{i_first}, obj.BinParams.stim.Legend_s.CLTA{binrange}))
						xlim(ax1, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax1, ['C/LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax1, 'Time wrt Cue (s)')
						ylabel(ax1, 'dF/F')
					end
					% 
					% 	Reset colors:
					% 
					if ~inset
			            C = linspecer(length(bins)); 
	            	end
	            	% 
	            	% 	LTA targets: (bin CENTERS)
	            	% 
	            	if strcmpi(centerORmin, 'min')
						binMinPos_LTA = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
						binMaxPos_CTA = cellfun(@(x) find(obj.Plot.CTA.xticks.s > x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
					elseif strcmpi(centerORmin, 'center')
						binMinPos_LTA = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
						binMaxPos_CTA = cellfun(@(x) find(obj.Plot.CTA.xticks.s > x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
					end
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing, 'moving'), {obj.BinnedData.stim.LTA.All}, 'UniformOutput', 0));
					% hold on	
					if strcmpi(centerORmin, 'min')
						plot(ax1, [obj.BinParams.stim.s(i_first).CLTA_Min,obj.BinParams.stim.s(i_first).CLTA_Min],[yMin, yMax], 'HandleVisibility','off', 'linewidth', lw);
		                for ibin = binrange
		                	plot(ax1, [obj.BinParams.stim.s(ibin).CLTA_Min,obj.BinParams.stim.s(ibin).CLTA_Min],[yMin, yMax], 'HandleVisibility','off', 'linewidth', lw);
	                    end
                    elseif strcmpi(centerORmin, 'center')
                    	plot(ax1, [obj.BinParams.stim.s(i_first).CLTA_Center,obj.BinParams.stim.s(i_first).CLTA_Center],[yMin, yMax], 'HandleVisibility','off', 'linewidth', lw);
		                for ibin = binrange
		                	plot(ax1, [obj.BinParams.stim.s(ibin).CLTA_Center,obj.BinParams.stim.s(ibin).CLTA_Center],[yMin, yMax], 'HandleVisibility','off', 'linewidth', lw);
	                    end
                	end	
					% 
					% 	Reset colors:
					% 
					if ~inset
			            C = linspecer(length(bins)); 
	            	end
	            	% 
	            	% 	LTA to BIN MIN -- so just plot up to lick and then have x-axis taken care of
	            	% 
            		CTA_s1 = LTA_trim_post_cue_s;
            		CTA_s2 = obj.Plot.CTA.xticks.s(binMaxPos_CTA{i_first});
            		LTA_pos1 = binMinPos_LTA{i_first} + LTA_trim_post_cue_pos;
            		LTA_pos2 = obj.Plot.lick_zero_position+1;
                    if strcmp(obj.iv.signaltype_, 'camera')
                        if isfield(obj.iv, 'camoFs')
							FS = obj.iv.camoFs;
						else
							FS = 30;
						end
                        tick = 1/FS;
                    elseif strcmp(obj.iv.signaltype_, 'photometry')
                        tick = 1/1000;
                    elseif strcmp(obj.iv.signaltype_, 'EMG') || strcmp(obj.iv.signaltype_, 'accelerometer')
                        tick = 1/2000;    
                    end
                    if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
                        pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
                        LTA_pos2 = LTA_pos2 + pad;
                    end
            		if LTA_pos2 - LTA_pos1 >0
		            	plot(ax1, CTA_s1:tick:CTA_s2+tail/1000, smoothedSets{1, i_first}(LTA_pos1:LTA_pos2+tail), 'linewidth', lw, 'HandleVisibility','off')
					else
						plot(ax1, [], 'HandleVisibility','off')
					end
					for ibin = binrange
	            		CTA_s1 = LTA_trim_post_cue_s;
	            		CTA_s2 = obj.Plot.CTA.xticks.s(binMaxPos_CTA{ibin});
	            		LTA_pos1 = binMinPos_LTA{ibin} + LTA_trim_post_cue_pos;
	            		LTA_pos2 = obj.Plot.lick_zero_position+1;
                        if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
                            pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
                            LTA_pos2 = LTA_pos2 + pad;
                        end
	            		if LTA_pos2 - LTA_pos1 >0
			            	plot(ax1, CTA_s1:tick:CTA_s2+tail/1000, smoothedSets{1, ibin}(LTA_pos1:LTA_pos2+tail), 'LineWidth', lw, 'HandleVisibility','off')
						else
							plot(ax1, [], 'HandleVisibility','off')
						end
                    end
					ylim(ax1, [yMin, yMax])
					% 
					% 	Set for printing:
					% 
					set(ax1, 'fontsize', 20)	
				end
				% 
				% 	Now the unstim plot:
				%		Handle bin mode 
				% 
				if ischar(bins0) && strcmpi(bins0, 'all')
					if ~strcmpi(pType, 'siITI')
						bins = 1:obj.BinParams.unstim.nbins_CLTA;
						% 
						% 	Handle ordering
						% 
						if strcmp(Order, 'first-to-last')
							disp('Plotting first-to-last bins')
							i_minus = false;
							i_first = bins(1);
							binrange = bins(2:end);
						else
							disp('Plotting last-to-first bins')
							i_minus = true;
							i_first = bins(end);
							binrange = flip(bins(1:end-1));
						end
						%  
					end
				end
				% 
				if strcmpi(pType, 'CTA')
					disp('~~~~~~~~~~~~~~Plotting CTA~~~~~~~~~~~~~~~~')
	                yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.unstim.CTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.unstim.CTA));
	                plot(ax2, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold(ax2, 'on');
					plot(ax2, obj.Plot.CTA.xticks.s,obj.smooth(obj.BinnedData.unstim.CTA{1, i_first},smoothing, 'moving'), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(ax2, obj.Plot.CTA.xticks.s, obj.smooth(obj.BinnedData.unstim.CTA{1, ibin},smoothing, 'moving'), 'linewidth', lw), end
						leg = obj.BinParams.unstim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.unstim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
						legend(ax2, leg)
						xlim(ax2, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax2, ['No-Stim CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Cue (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					else
						for ibin = binrange, plot(ax2, obj.Plot.CTA.xticks.s, obj.smooth(obj.BinnedData.unstim.CTA{1, ibin}, smoothing, 'moving'), 'linewidth', lw), end
						legend(ax2, horzcat({'cue'}, obj.BinParams.unstim.Legend_s.CLTA{i_first}, obj.BinParams.unstim.Legend_s.CLTA{binrange}))
						xlim(ax2, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax2, ['No-Stim CTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Cue (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					end
					linkaxes([ax1, ax2], 'xy')
					% 
				elseif strcmpi(pType, 'CTA2l')
					disp('~~~~~~~~~~~~~~Plotting CTA up to first lick~~~~~~~~~~~~~~~~')
					binMinPos = cellfun(@(x) find(obj.Plot.CTA.xticks.s > x, 1, 'first'), {obj.BinParams.unstim.s(1:obj.BinParams.unstim.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing, 'moving'), obj.BinnedData.unstim.CTA, 'UniformOutput', 0));
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.unstim.CTA(binrange)));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.unstim.CTA(binrange)));
	                plot(ax2, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold(ax2, 'on');
					if i_minus
		                plot(ax2, obj.Plot.CTA.xticks.s(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, 
	                        plot(ax2, obj.Plot.CTA.xticks.s(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), 
	                    end
						leg = obj.BinParams.stim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.stim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
	                    legend(ax2, leg)
						xlim(ax2, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax2,['Stim- CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Cue (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					else
        				plot(ax2, obj.Plot.CTA.xticks.s(1:binMinPos{i_first}), smoothedSets{1, i_first}(1:binMinPos{i_first}), 'linewidth', lw)
						for ibin = binrange, plot(ax2, obj.Plot.CTA.xticks.s(1:binMinPos{ibin}), smoothedSets{1, ibin}(1:binMinPos{ibin}), 'linewidth', lw), end
						legend(ax2, horzcat({'cue'}, obj.BinParams.stim.Legend_s.CLTA{i_first}, obj.BinParams.stim.Legend_s.CLTA{binrange}))
						xlim(ax2, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax2, ['Stim- CTA up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Cue (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					end	
					linkaxes([ax1, ax2], 'xy')
					% 
				elseif strcmpi(pType, 'LTA') 
					disp('~~~~~~~~~~~~~~Plotting LTA~~~~~~~~~~~~~~~~')
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.unstim.LTA.All}));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.unstim.LTA.All}));
	                plot(ax2, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Lick')
					hold(ax2, 'on');
					plot(ax2, obj.Plot.LTA.xticks.s,obj.smooth(obj.BinnedData.unstim.LTA(i_first).All,smoothing, 'moving'), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(ax2, obj.Plot.LTA.xticks.s, obj.smooth(obj.BinnedData.unstim.LTA(ibin).All,smoothing, 'moving'), 'linewidth', lw), end
						leg = obj.BinParams.unstim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.unstim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
						legend(ax2, leg)
						xlim(ax2, [-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(ax2, ['Stim- LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt First Lick (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					else
						for ibin = binrange, plot(ax2, obj.Plot.LTA.xticks.s, obj.smooth(obj.BinnedData.unstim.LTA(ibin).All, smoothing, 'moving'), 'linewidth', lw), end
						leg = horzcat({'cue'}, obj.BinParams.stim.Legend_s.CLTA{i_first}, obj.BinParams.unstim.Legend_s.CLTA{binrange});
	                    legend(ax2, leg)
						xlim(ax2, [-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(ax2, ['Stim- LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt First Lick (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					end
					linkaxes([ax1, ax2], 'xy')
					% 
				elseif strcmpi(pType, 'LTA2l')

					disp('~~~~~~~~~~~~~~Plotting unstim LTA trimmed to cue~~~~~~~~~~~~~~~~')
					binMinPos = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), {obj.BinParams.unstim.s.CLTA_Min}, 'UniformOutput', false);
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing, 'moving'), {obj.BinnedData.unstim.LTA.All}, 'UniformOutput', 0));
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.unstim.LTA(binrange).All}));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), {obj.BinnedData.unstim.LTA(binrange).All}));
	                plot(ax2, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'First Lick')
					hold(ax2, 'on');
					if i_minus
		                plot(ax2, obj.Plot.LTA.xticks.s(binMinPos{i_first}:end), smoothedSets{1, i_first}(binMinPos{i_first}:end), 'linewidth', lw)
						for ibin = binrange, 
	                        plot(ax2, obj.Plot.LTA.xticks.s(binMinPos{ibin}:end), smoothedSets{1, ibin}(binMinPos{ibin}:end), 'linewidth', lw), 
	                    end
						leg = obj.BinParams.unstim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.unstim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
	                    legend(ax2, leg)
						xlim(ax2, [obj.Plot.LTA.xticks.s(min(cellfun(@(x) min(x), binMinPos))), 10])
						title(ax2, ['LTA+unstim up to Cue: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Lick (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					else
        				plot(ax2, obj.Plot.CTA.xticks.s(binMinPos{i_first}:end), smoothedSets{1, i_first}(binMinPos{i_first}:end), 'linewidth', lw)
						for ibin = binrange, plot(ax2, obj.Plot.CTA.xticks.s(binMinPos{ibin}:end), smoothedSets{1, ibin}(binMinPos{ibin}:end), 'linewidth', lw), end
						legend(ax2, horzcat({'lick'}, obj.BinParams.unstim.Legend_s.CLTA{i_first}, obj.BinParams.unstim.Legend_s.CLTA{binrange}))
						xlim(ax2, [min(binMinPos), 10])
						title(ax2, ['LTA+unstim up to Lick: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Lick (s)')
						ylabel(ax2, 'dF/F')
						ylim(ax2, [yMin, yMax])
					end	
					linkaxes([ax1, ax2], 'xy')
					% 
				elseif strcmpi(pType, 'CLTA')
					C = linspecer(length(bins)); 
					% ax2 = subplot(1,2,2);
					CTA_cutoff_s = 0 + 0.5;
					CTA_cutoff_pos = obj.Plot.first_post_cue_position + 500; 
					LTA_trim_post_cue_pos = 700;
					LTA_trim_post_cue_s = 0.7;


					disp('~~~~~~~~~~~~~~Plotting unstim CLTA~~~~~~~~~~~~~~~~')
	                yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.unstim.CTA));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.unstim.CTA));
	                plot(ax2, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Cue')
					hold(ax2, 'on');
					plot(ax2, obj.Plot.CTA.xticks.s(1:CTA_cutoff_pos),obj.smooth(obj.BinnedData.unstim.CTA{1, i_first}(1:CTA_cutoff_pos),smoothing, 'moving'), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(ax2, obj.Plot.CTA.xticks.s(1:CTA_cutoff_pos), obj.smooth(obj.BinnedData.unstim.CTA{1, ibin}(1:CTA_cutoff_pos),smoothing, 'moving'), 'linewidth', lw), end
						leg = obj.BinParams.unstim.Legend_s.CLTA(binrange);
	                    leg2 = {obj.BinParams.unstim.Legend_s.CLTA{i_first}};
	                    leg = horzcat({'cue'}, leg2, leg);
						legend(ax2, leg)
						xlim(ax2, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax2, ['C/LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Cue (s)')
						ylabel(ax2, 'dF/F')
					else
						for ibin = binrange, plot(ax2, obj.Plot.CTA.xticks.s(1:CTA_cutoff_pos), obj.smooth(obj.BinnedData.unstim.CTA{1, ibin}(1:CTA_cutoff_pos), smoothing, 'moving'), 'linewidth', lw), end
						legend(ax2, horzcat({'cue'}, obj.BinParams.unstim.Legend_s.CLTA{i_first}, obj.BinParams.unstim.Legend_s.CLTA{binrange}))
						xlim(ax2, [-obj.Plot.wrtCTAArray.Events.s.first_post_cue_position, obj.Plot.wrtCue.Events.s.total_time_ms])
						title(ax2, ['C/LTA: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel(ax2, 'Time wrt Cue (s)')
						ylabel(ax2, 'dF/F')
					end
					% 
					% 	Reset colors:
					% 
					if ~inset
			            C = linspecer(length(bins)); 
	            	end
	            	% 
	            	% 	LTA targets: (bin CENTERS)
	            	% 
					if strcmpi(centerORmin, 'min')
						binMinPos_LTA = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
						binMaxPos_CTA = cellfun(@(x) find(obj.Plot.CTA.xticks.s > x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
					elseif strcmpi(centerORmin, 'center')
						binMinPos_LTA = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
						binMaxPos_CTA = cellfun(@(x) find(obj.Plot.CTA.xticks.s > x, 1, 'first'), {obj.BinParams.stim.s(1:obj.BinParams.stim.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
					end
					smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing, 'moving'), {obj.BinnedData.unstim.LTA.All}, 'UniformOutput', 0));
					% hold on		
	                if strcmpi(centerORmin, 'min')
						plot(ax2, [obj.BinParams.stim.s(i_first).CLTA_Min,obj.BinParams.stim.s(i_first).CLTA_Min],[yMin, yMax], 'HandleVisibility','off');
		                for ibin = binrange
		                	plot(ax2, [obj.BinParams.stim.s(ibin).CLTA_Min,obj.BinParams.stim.s(ibin).CLTA_Min],[yMin, yMax], 'HandleVisibility','off');
	                    end
                    elseif strcmpi(centerORmin, 'center')
                    	plot(ax2, [obj.BinParams.stim.s(i_first).CLTA_Center,obj.BinParams.stim.s(i_first).CLTA_Center],[yMin, yMax], 'HandleVisibility','off');
		                for ibin = binrange
		                	plot(ax2, [obj.BinParams.stim.s(ibin).CLTA_Center,obj.BinParams.stim.s(ibin).CLTA_Center],[yMin, yMax], 'HandleVisibility','off');
	                    end
                	end	
					% 
					% 	Reset colors:
					% 
					if ~inset
			            C = linspecer(length(bins)); 
	            	end
	            	% 
	            	% 	LTA to BIN MIN -- so just plot up to lick and then have x-axis taken care of
	            	% 
            		CTA_s1 = LTA_trim_post_cue_s;
            		CTA_s2 = obj.Plot.CTA.xticks.s(binMaxPos_CTA{i_first});
            		LTA_pos1 = binMinPos_LTA{i_first} + LTA_trim_post_cue_pos;
            		LTA_pos2 = obj.Plot.lick_zero_position+1;
                    if strcmp(obj.iv.signaltype_, 'camera')
                        if isfield(obj.iv, 'camoFs')
							FS = obj.iv.camoFs;
						else
							FS = 30;
						end
                        tick = 1/FS;
                    elseif strcmp(obj.iv.signaltype_, 'photometry')
                        tick = 1/1000;
                    elseif strcmp(obj.iv.signaltype_, 'EMG') || strcmp(obj.iv.signaltype_, 'accelerometer')
                        tick = 1/2000;    
                    end
                    if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
                        pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
                        LTA_pos2 = LTA_pos2 + pad;
                    end
            		if LTA_pos2 - LTA_pos1 >0
		            	plot(ax2, CTA_s1:tick:CTA_s2+tail/1000, smoothedSets{1, i_first}(LTA_pos1:LTA_pos2+tail), 'linewidth', lw, 'HandleVisibility','off')
					else
						plot(ax2, [], 'HandleVisibility','off')
					end
					for ibin = binrange
	            		CTA_s1 = LTA_trim_post_cue_s;
	            		CTA_s2 = obj.Plot.CTA.xticks.s(binMaxPos_CTA{ibin});
	            		LTA_pos1 = binMinPos_LTA{ibin} + LTA_trim_post_cue_pos;
	            		LTA_pos2 = obj.Plot.lick_zero_position+1;
                        if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
                            pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
                            LTA_pos2 = LTA_pos2 + pad;
                        end
	            		if LTA_pos2 - LTA_pos1 >0
			            	plot(ax2, CTA_s1:tick:CTA_s2+tail/1000, smoothedSets{1, ibin}(LTA_pos1:LTA_pos2+tail), 'LineWidth', lw, 'HandleVisibility','off')
						else
							plot(ax2, [], 'HandleVisibility','off')
						end
                    end
					ylim(ax2, [yMin, yMax])
					% 
					% 	Set for printing:
					% 
					set(ax1, 'fontsize', 20);
					set(ax2, 'fontsize', 20);
					linkaxes([ax1, ax2], 'xy')	
				end
			    % 
				% 	Now handle the siITI case...
				% 
				if strcmp(pType, 'siITI') % There is no unstim case for this...
					f1 = figure;
					C = linspecer(length(bins)); 
		            axes('NextPlot','replacechildren', 'ColorOrder',C);
					ax1 = subplot(1,1,1);
					disp('~~~~~~~~~~~~~~Plotting siITI LTA~~~~~~~~~~~~~~~~')
					yMin = nanmin(cellfun(@(x) nanmin(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.siITI));
					yMax = nanmax(cellfun(@(x) nanmax(obj.smooth(x, smoothing, 'moving')), obj.BinnedData.siITI));
	                plot(ax1, [0,0],[yMin, yMax], 'k-', 'DisplayName', 'Lick')
					hold(ax1, 'on');
					plot(ax1, obj.Plot.siITI.xticks.s,obj.smooth(obj.BinnedData.siITI{i_first},smoothing, 'moving'), 'linewidth', lw)
					if i_minus
						for ibin = binrange, plot(ax1, obj.Plot.siITI.xticks.s, obj.smooth(obj.BinnedData.siITI{ibin},smoothing, 'moving'), 'linewidth', lw), end
						leg = obj.BinParams.Legend_s.siITI(binrange);
	                    leg2 = {obj.BinParams.Legend_s.siITI{i_first}};
	                    leg = horzcat({'lick'}, leg2, leg);
						legend(leg)
						xlim([-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(['siITI: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Self-Initiated ITI Lick (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					else
						for ibin = binrange, plot(ax1, obj.Plot.siITI.xticks.s, obj.smooth(obj.BinnedData.siITI{ibin}, smoothing, 'moving'), 'linewidth', lw), end
						leg = horzcat({'cue'}, obj.BinParams.Legend_s.siITI{i_first}, obj.BinParams.Legend_s.siITI{binrange});
	                    legend(leg)
						xlim([-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
						title(['siITI: Bins ', num2str(bins(1)), '-', num2str(bins(end))])
						xlabel('Time wrt Self-Initiated ITI Lick (s)')
						ylabel('dF/F')
						ylim([yMin, yMax])
					end
				end
			end

			set(gca, 'fontsize', fontSz);
			% 
			% 
			% 
		end

		function sts = smooth(obj, ts, OnOff, method)
			% 
			% OnOff = 0: no smoothing
			% OnOff > 0: the kernel is OnOff
			% 
			if nargin < 4
				method = 'gausssmooth';
			end
			if nargin < 3 || OnOff < 0
				OnOff = obj.Plot.smooth_kernel;
            end
            
            if isempty(ts), sts = []; return, end

			if strcmp(method, 'gausssmooth')
				if OnOff
					sts = gausssmooth(ts, round(OnOff), 'gauss');
				else
					sts = ts;
				end
			else
				if OnOff
					sts = smooth(ts, round(OnOff), 'moving');
				else
					sts = ts;
				end
			end
		end


	%-------------------------------------------------------
	% 		Methods: Stat helpers
	%-------------------------------------------------------
		function [rsq, yresid] = rSquared(obj, y, yfit)
			% 
			% 	y = observed y-axis
			% 	yfit = modeled y
			% 
			yresid = y - yfit;
			SSresid = nansum(yresid.^2);
			SStotal = (length(y) - 1)*nanvar(y);
			rsq = 1 - SSresid/SStotal;
		end

		function [r, rsq] = rCorrCoeff(obj, y, yfit)
			rmat = corrcoef(y,yfit);
			r = rmat(2,1);
			rsq = r^2;
		end

		function Nans = zero2nan(obj, Zeros, onesMode)
			% 
			%  Convert all zeros to NaN
			% 		** Use onesMode to also convert 1s to nan. This is helpful if don't want to include bins already above thresh in the model
			% 
			if nargin < 3
				onesMode = false;
			end
			Zeros(Zeros == 0) = nan;
			if onesMode
				Zeros(Zeros == 1) = nan;
			end
			Nans = Zeros;
		end

		function x = nanORidx(obj, idx, r)
			% 
			%  if X is nan, return nan. Otherwise, use as index to second array.
			% 
			if isnan(idx)
				x = nan;
			else
				x = r(idx);
			end
		end

		function Trim = nanTrim(obj, curve, nanMin, nanMax)
			% 
			%  set all points from nanmin:nanmax to nan
			% 
			curve(nanMin:nanMax) = NaN;
            Trim = curve;
		end


	%-------------------------------------------------------
	%		Methods: Statistical tests and plot commands
	%-------------------------------------------------------
		function horizontalThreshold(obj, Mode, bins, nthresh, delay, direction, Plot, smoothing, useTS)
			% 
			% 	Mode: 
			% 		'LTA': 		Will do in negative time wrt lick
			% 
			% 		'CTA2l': 	Will do wrt cue, but also can add a delay to ignore the initial bump, default zero
			% 
			% 		'SingleTrial':	Goes in CTA mode up to the time of lick and sees what the activity is around that time.
			% 					Then it will plot this for us and also give us an R**2 plot
			% 
			% 		'Pickthresh':	Does CTA2l mode for specified threshold levels -- specify as dF/F
			% 
			% 	bins:
			% 		A list with the bins to be included in the analysis. Default is 'all'. Can specify as [1,4,9], etc. If specified bin is not in range, it is ignored
			% 
			% 	nthresh:
			% 		Number of thresholds to array, spaced evenly along the y-space. Default is 1, right at the midpoint
			% 
			% 	delay:
			% 		in ms, ignores a certain amount of time after the cue wrt the threshold crossing
			% 	
			% 	direction:
			% 		default: '+'. Can change this to '-' if you want to look at a downward threshold crossing
			% 
			% 	Plot:
			% 		set to 0 or false to suppress plots
			% ---------------------------------------------------------------
			
			disp('Initializing horizontal threshold model ---------------------')
			% 
			if nargin < 9
				useTS = false;
			end
			if nargin < 8
				smoothing = obj.Plot.smooth_kernel;
			end
			if nargin < 7 || ~islogical(Plot)
				disp('		Allowing plots')
				Plot = true;
			end
			if nargin < 6 || ~strcmp(direction, '+') && ~strcmp(direction, '-')
				disp('		Using ''+'' direction')
				direction = '+';
			end
			if nargin < 5 || ~isnumeric(delay)
				disp('		Using 0ms delay for CTA2l (warning: only use int in ms for delay term)')
				delay = 0;
			else
				delay = round(delay);
				disp(['		Using ' num2str(delay) 'ms delay for CTA2l (warning: only use int in ms for delay term)'])
			end
			if nargin < 4 || numel(nthresh) == 1 && nthresh < 1
				disp('		Using only one threshold, at the midpoint.')
				nthresh = 1;
				nbreaks = 2;
			elseif numel(nthresh) > 1
				disp(['		UI determined thresholds to test. Testing: ' num2str(nthresh)])
			else
				nthresh = round(nthresh);
				disp(['		Using threshold ' num2str(nthresh) ' , at the midpoint.'])
				nbreaks = nthresh + 1;
			end
			if nargin < 3 || strcmpi(bins, 'all')
				disp('		Using default bins: ''all''')
				if useTS
					bins = 1:obj.ts.BinParams.nbins_CLTA;
				else
					bins = 1:obj.BinParams.nbins_CLTA;
				end
			elseif sum(ismember(bins, 1:obj.BinParams.nbins_CLTA)) < length(bins)
				warning(['An input bin is out of range. This will be ignored. There are only ', num2str(obj.BinParams.nbins_CLTA), ' CLTA bins total.'])
			end
			
			%	 
			% 	Determine the type of model - CTA2l or LTA
			% 
			if strcmpi(Mode, 'LTA')
				if useTS
					BinParams = obj.ts.BinParams;
					xticks = obj.ts.Plot.LTA.xticks.s;
                    BinnedData.LTA = obj.ts.BinnedData.LTA(bins);                    
				else
					BinParams = obj.BinParams;
					xticks = obj.Plot.LTA.xticks.s;
                    BinnedData.LTA = {obj.BinnedData.LTA(bins).All};
				end
					
				% 
				% 	Initilize a structure to keep track of the results of the analysis in .Stat
				% 
				% 
				% 	NOTE: ONLY INDEX FOR INCLUDED BINS!
				% 
				if isfield(obj.Stat, 'hThresh') && isfield(obj.Stat.hThresh, 'LTA')
					analysisNum = length(obj.Stat.hThresh(end).LTA) + 1;
					obj.Stat.hThresh(analysisNum).LTA = {};
				else
					analysisNum = 1;
					obj.Stat.hThresh(analysisNum).LTA = {};
				end
				% 
				% 	For each bin, find the crossing time in x (s)
				% 
				% 		For each bin, we have a different range of xmin times to consider - obviously doesn't make sense to look at times before the cue
				% 		THUS only look until the right side of the bin, which is the furthest back time without pre-cue times for that bin
				% 
				binTimeMin = {BinParams.s(bins).CLTA_Min};
				xmins = cellfun(@(x) find(xticks > -x, 1, 'first'), binTimeMin);
				xmin = min(xmins);
				xmax = find(xticks > 0, 1, 'first');
				% 
				% 	Find the range over which (in y-axis) to test thresholds and thresholds to test
				% 
				smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), BinnedData.LTA, 'UniformOutput', 0));
				% 
				if numel(nthresh) == 1
					yMin = nanmin(cell2mat(cellfun(@(x,y) nanmin(x(xmins(y):xmax)), smoothedSets, num2cell(1:numel(bins)), 'UniformOutput', 0)));
					yMax = nanmax(cell2mat(cellfun(@(x,y) nanmax(x(xmins(y):xmax)), smoothedSets, num2cell(1:numel(bins)), 'UniformOutput', 0)));
					yspan = yMax-yMin;
					ytix = yspan/nbreaks;
					yPos = [yMin:ytix:yMax];		% this includes the min and max, which there's no point in testing
					yThresh = yPos(2:end-1); 		% this only has the thresholds which will be tested
				else
					yThresh = nthresh;
					nthresh = numel(nthresh); 
				end
				% 
				% 	Collect the crossing times in s
				% 
				xingtimes = {};
				xingpos = {};

				rsq = nan(nthresh, 1);
				if Plot
					f1 = figure; 
					% 
					% 	Plot the smoothed curves with thresholds on the
					% 	left (looks good 10/7/18)
					% 
		            ax0 = subplot(1,3,1);
					C = linspecer(nthresh); 
					blacks = zeros(numel(bins) - numel(xmins ==0),3);
		            
		            if useTS
		            	obj.plot('LTA', bins, true, smoothing, 'last-to-first', true);
	            	else
						obj.plot('LTA', bins, true, smoothing, 'last-to-first', false);
            		end
	            		
	            	hold on
					set(ax0, 'ColorOrder',[blacks;C]);
	            	cellfun(@(x,y) plot([xticks(xmin), xticks(xmax)], [x,x], 'DisplayName', ['Threshold #' num2str(y), ' ', num2str(yThresh(y))]), num2cell(yThresh), num2cell(1:nthresh));
	            	legend('show')
					% 
					% 	The middle pannel is for the regression
					% 
		            ax1 = subplot(1,3,2);
	            	plot(ax1, [0,cell2mat(binTimeMin(numel(bins)))], -[0,cell2mat(binTimeMin(numel(bins)))], 'k-', 'DisplayName', 'meridian')
	            	C2 = reshape([C,C]',3,2*nthresh)';
	            	set(ax1, 'ColorOrder',C2);
	            	xlabel('Earliest Lick Time (s)')
					ylabel('Threshold Crossing Time wrt Lick (s)')
	            	hold on
				end
				for ithresh = 1:nthresh
					% 
					% 	Find the first crossing time in the range from cue-to-lick. 
					%   So if bin is -500ms and it crosses as -250, this will find the 
					% 	position of the crossing to be 250 for photometry and 500 for movement
					% ***** NOTE: if curve is already above thresh at edge of bin, then exclude this using onesMode = true in zero2nan
					% 
					if strcmp(direction, '+')
						xingpos(ithresh).thresh = cellfun(@(x,y) nansum([find(x(y:xmax) > yThresh(ithresh), 1, 'first'), nan]), smoothedSets, num2cell(xmins), 'UniformOutput', 0);
						xingpos(ithresh).thresh = cellfun(@(x) obj.zero2nan(x, true), xingpos(ithresh).thresh, 'UniformOutput', 0);
					elseif strcmp(direction, '-')
						xingpos(ithresh).thresh = cellfun(@(x,y) nansum([find(x(y:xmax) < yThresh(ithresh), 1, 'first'), nan]), smoothedSets, num2cell(xmins), 'UniformOutput', 0);
						xingpos(ithresh).thresh = cellfun(@(x) obj.zero2nan(x, true), xingpos(ithresh).thresh, 'UniformOutput', 0);
					end
					% 
					% 	We then need to convert everything to absolute position within the LTA array.
					% 		Thus e/a xingtime should be position of lick (xmax) - numel(x(y:xmax)) + original xingtime
					% 
					xingpos(ithresh).thresh = cellfun(@(data,xp,xm) xmax - numel(data(xm:xmax)) + xp, smoothedSets, xingpos(ithresh).thresh, num2cell(xmins), 'UniformOutput', 0);
					% 
					% 	Now, convert to time in seconds before the lick (looks good, 10/7/18)
					% 
					xingtimes(ithresh).thresh = cellfun(@(idx) obj.nanORidx(idx, xticks), xingpos(ithresh).thresh);
					% 
					%	Now, for each threshold, we will regress the crossing times for each bin against the right** edge of bin
					% 		*** CHECK THAT NANs or NOXINGS don't screw up glmfit
					% 
					iThresh_binTimeMin = cell2mat(binTimeMin);
					iThresh_binTimeMin(isnan(xingtimes(ithresh).thresh)) = [];
					iThresh_xingtimes = xingtimes(ithresh).thresh;
					iThresh_xingtimes(isnan(iThresh_xingtimes)) = [];
					[b, dev, stats] = glmfit(iThresh_binTimeMin,iThresh_xingtimes);
					yfit = glmval(b,iThresh_binTimeMin, 'identity');
					nPoints(ithresh) = numel(yfit);
					[rsq(ithresh), ~] = obj.rSquared(iThresh_xingtimes', yfit);
					% [rsq(ithresh), ~] = rsquare(yfit',-cell2mat(binTimeMin(bins))); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THIS ISN'T WORKING
					% rsq(ithresh) = stats.Rsquared.Adjusted;
					if Plot
						if isinf(rsq(ithresh)) || isnan(rsq(ithresh)) || nPoints(ithresh) == 2
							plot3(ax1, [0,0.01],[0,0.01],[0,0.01],'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh))])
						else
							plot3(ax1, iThresh_binTimeMin,yfit,zeros(size(yfit)),'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh))])
						end
						scatter3(ax1, iThresh_binTimeMin,iThresh_xingtimes,bins(~isnan(iThresh_xingtimes)), '.', 'LineWidth', 2, 'DisplayName', ['Threshold #', num2str(ithresh), ' y=' num2str(yThresh(ithresh))])
					end
					zlabel(ax1, 'Bin #')
					obj.Stat.hThresh(analysisNum).LTA.b{ithresh} = b;
					obj.Stat.hThresh(analysisNum).LTA.dev{ithresh} = dev;
					obj.Stat.hThresh(analysisNum).LTA.stats(ithresh) = stats;
				end
				legend('show')
				title('Threshold Crossing Time wrt Lick vs Lick Time wrt Cue')
				% 
				%	Finally, plot the R^2 vs threshold 
				% 
				if Plot
					ax2 = subplot(1,3,3);
				else
					f2 = figure;
				end
				hold(ax2, 'on');
				set(ax2, 'ColorOrder',C);
				for ithresh = 1:nthresh
					if isnan(rsq(ithresh)) || nPoints(ithresh) == 2
						plot(ax2, yThresh(ithresh), 0, '.', 'LineWidth', 3);
					else
						plot(ax2, yThresh(ithresh), rsq(ithresh), '.', 'LineWidth', 3);
					end
				end
				ylim([0,1])
				title('R^2 vs threshold')
				xlabel('Y Threshold')
				ylabel('R^2')
				% 
				% 	Save the analysis results to the structure
				% 
				obj.Stat.hThresh(analysisNum).LTA.yThresh = yThresh;
				obj.Stat.hThresh(analysisNum).LTA.bins = bins;
				obj.Stat.hThresh(analysisNum).LTA.direction = direction;
				obj.Stat.hThresh(analysisNum).LTA.xingpos = xingpos;
				obj.Stat.hThresh(analysisNum).LTA.xingtimes_s = xingtimes;
				obj.Stat.hThresh(analysisNum).LTA.rsq = rsq;









			elseif strcmpi(Mode, 'CTA2l') || strcmpi(Mode, 'Pickthresh')
				if useTS
					BinParams = obj.ts.BinParams;
					xticks = obj.ts.Plot.CTA.xticks.s;
                    BinnedData.CTA = obj.ts.BinnedData.CTA(bins);                    
				else
					BinParams = obj.BinParams;
					xticks = obj.Plot.CTA.xticks.s;
                    BinnedData.CTA = obj.BinnedData.CTA(bins);
				end
				% 
				% 	Initilize a structure to keep track of the results of the analysis in .Stat
				% 
				if isfield(obj.Stat, 'hThresh') && isfield(obj.Stat.hThresh, 'CTA2l')
					analysisNum = length(obj.Stat.hThresh(end).CTA2l) + 1;
					obj.Stat.hThresh(analysisNum).CTA2l = {};
				else
					analysisNum = 1;
					obj.Stat.hThresh(analysisNum).CTA2l = {};
				end	
				% 
				% 	For each bin, find the crossing time in x (s)
				% 
				% 		For each bin, we have a different range of xmin times to consider - obviously doesn't make sense to look at times before the cue
				% 		THUS only look until the right side of the bin, which is the furthest back time without pre-cue times for that bin
				% 
				binTimeMin = {BinParams.s(bins).CLTA_Min};
				xmaxs = cellfun(@(x) find(xticks > x, 1, 'first'), binTimeMin);
				xmax = max(xmaxs);
				xmin = find(xticks > 0 + delay/1000, 1, 'first');
				% 
				% 	Find the range over which (in y-axis) to test thresholds and thresholds to test
				% 
				smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), BinnedData.CTA, 'UniformOutput', 0));
				% 
				if ~strcmpi(Mode, 'Pickthresh')
					if numel(nthresh) == 1
						yMin = nanmin(cell2mat(cellfun(@(x,y) nanmin(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
						yMax = nanmax(cell2mat(cellfun(@(x,y) nanmax(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
						yspan = yMax-yMin;
						ytix = yspan/nbreaks;
						yPos = [yMin:ytix:yMax];		% this includes the min and max, which there's no point in testing
						yThresh = yPos(2:end-1); 		% this only has the thresholds which will be tested
					else
						yThresh = nthresh;
						nthresh = numel(nthresh);
						yMin = nanmin(cell2mat(cellfun(@(x,y) nanmin(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
						yMax = nanmax(cell2mat(cellfun(@(x,y) nanmax(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
					end
				else
					yThresh = nthresh;
					nthresh = numel(nthresh);
					yMin = nanmin(cell2mat(cellfun(@(x,y) nanmin(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
					yMax = nanmax(cell2mat(cellfun(@(x,y) nanmax(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
				end
				% 
				% 	Collect the crossing times in s
				% 
				xingtimes = {};
				xingpos = {};
				actualMoveTime = {};
				nbinsXing = [];

				rsq = nan(nthresh, 1);
				if Plot
					f1 = figure; 
					% 
					% 	Plot the smoothed curves with thresholds on the
					% 	left (looks good 10/7/18)
					% 
					C = linspecer(nthresh); 
					blacks = zeros(numel(bins) - numel(xmaxs ==0),3); 
		            ax0 = subplot(1,3,1);
		            if useTS
		            	obj.plot('CTA2l', bins, true, smoothing, 'last-to-first', true);
	            	else
						obj.plot('CTA2l', bins, true, smoothing, 'last-to-first', false);
            		end
	            	
	            	hold on
	            	set(ax0, 'ColorOrder',[blacks;C]);
	            	cellfun(@(x,y) plot(ax0, [xticks(xmin), xticks(xmax)], [x,x], 'DisplayName', ['Threshold #' num2str(y), ' ', num2str(yThresh(y))]), num2cell(yThresh), num2cell(1:nthresh));
	            	legend('show')
	            	ylim([yMin,yMax]);
	            	xlim([xticks(1), cell2mat(binTimeMin(numel(bins)))])
					% 
					% 	The middle pannel is for the regression
					% 
		            

		            ax1 = subplot(1,3,2);
	            	plot(ax1, [0,cell2mat(binTimeMin(numel(bins)))], [0,cell2mat(binTimeMin(numel(bins)))], 'k-', 'DisplayName', 'meridian')
	            	C2 = reshape([C,C]',3,2*nthresh)';
	            	set(ax1, 'ColorOrder',C2);
	            	xlabel('Earliest Lick Time (s)')
					ylabel('Threshold Crossing Time wrt Cue (s)')
	            	hold on
				end
				for ithresh = 1:nthresh
					% 
					% 	Find the first crossing time in the range from cue-to-lick. 
					%   So if bin is -500ms and it crosses as -250, this will find the 
					% 	position of the crossing to be 250 for photometry and 500 for movement
					% ***** NOTE: if curve is already above thresh at edge of bin, then exclude this using onesMode = true in zero2nan
					% 
					if strcmp(direction, '+')
						xingpos(ithresh).thresh = cellfun(@(x,y) nansum([find(x(xmin:y) > yThresh(ithresh), 1, 'first'), nan]), smoothedSets([1:numel(bins)]), num2cell(xmaxs), 'UniformOutput', 0);
						xingpos(ithresh).thresh = cellfun(@(x) obj.zero2nan(x, true), xingpos(ithresh).thresh, 'UniformOutput', 0);
					elseif strcmp(direction, '-')
						xingpos(ithresh).thresh = cellfun(@(x,y) nansum([find(x(xmin:y) < yThresh(ithresh), 1, 'first'), nan]), smoothedSets([1:numel(bins)]), num2cell(xmaxs), 'UniformOutput', 0);
						xingpos(ithresh).thresh = cellfun(@(x) obj.zero2nan(x, true), xingpos(ithresh).thresh, 'UniformOutput', 0);
					end
					% 
					% 	We then need to convert everything to absolute position within the LTA array.
					% 		Thus e/a xingtime should be position of lick (xmax) - numel(x(y:xmax)) + original xingtime
					% 
					xingpos(ithresh).thresh = cellfun(@(data,xp,xm) xm - numel(data(xmin:xm)) + xp, smoothedSets, xingpos(ithresh).thresh, num2cell(xmaxs), 'UniformOutput', 0);
					% 
					% 	Now, convert to time in seconds before the lick (looks good, 10/7/18)
					% 
					xingtimes(ithresh).thresh = cellfun(@(idx) obj.nanORidx(idx, xticks), xingpos(ithresh).thresh);
					nbinsXing(ithresh) = sum(~isnan(cell2mat(xingpos(ithresh).thresh)));
					% 
					%	Now, for each threshold, we will regress the crossing times for each bin against the right** edge of bin
					% 		*** CHECK THAT NANs or NOXINGS don't screw up glmfit
					% 
					iThresh_binTimeMin = cell2mat(binTimeMin);
					iThresh_binTimeMin(isnan(xingtimes(ithresh).thresh)) = [];
					actualMoveTime(ithresh).thresh = iThresh_binTimeMin;
					iThresh_xingtimes = xingtimes(ithresh).thresh;
					iThresh_xingtimes(isnan(iThresh_xingtimes)) = [];
					[b, dev, stats] = glmfit(iThresh_binTimeMin,iThresh_xingtimes);
					yfit = glmval(b,iThresh_binTimeMin, 'identity');
                    if numel(yfit) > 2
    					slope(ithresh) = (yfit(end) - yfit(1))/(iThresh_binTimeMin(end) - iThresh_binTimeMin(1));
                    else
                        slope(ithresh) = nan;
                    end
					nPoints(ithresh) = numel(yfit);
					[rsq(ithresh), ~] = obj.rSquared(iThresh_xingtimes', yfit);	 
					% [b, dev, stats] = glmfit(cell2mat(binTimeMin(bins)),xingtimes(ithresh).thresh);
					% yfit = glmval(b,cell2mat(binTimeMin(bins)), 'identity');
					% [rsq(ithresh), ~] = obj.rSquared(xingtimes(ithresh).thresh', yfit);
					% [rsq(ithresh), ~] = rsquare(yfit',-cell2mat(binTimeMin(bins))); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THIS ISN'T WORKING
					% rsq(ithresh) = stats.Rsquared.Adjusted;
					if Plot
						if isinf(rsq(ithresh)) || isnan(rsq(ithresh)) || nPoints(ithresh) == 2
							plot3(ax1, [0,0.01],[0,0.01],[0,0.01],'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh))])
						else
							plot3(ax1, iThresh_binTimeMin,yfit,zeros(size(yfit)),'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh))])
						end
						scatter3(ax1, iThresh_binTimeMin,iThresh_xingtimes,bins(~isnan(iThresh_xingtimes)), '.', 'LineWidth', 0.5, 'DisplayName', ['#', num2str(ithresh), ' nbins=' num2str(nbinsXing(ithresh)) ' y=' num2str(yThresh(ithresh))])
					end
					zlabel(ax1, 'Bin #')

					obj.Stat.hThresh(analysisNum).CTA2l.b{ithresh} = b;
					obj.Stat.hThresh(analysisNum).CTA2l.dev{ithresh} = dev;
					obj.Stat.hThresh(analysisNum).CTA2l.stats(ithresh) = stats;
				end
				legend(ax1, 'show')
				colormap(ax1, C);
				caxis(ax1, [yThresh(1), yThresh(end)]);
				h = colorbar(ax1);
				ylabel(h, 'Threshold Crossing (dF/F)')
				title(ax1, 'Threshold Crossing Time wrt Lick vs Lick Time wrt Cue')
				% 
				%	Finally, plot the R^2 vs threshold 
				% 
				if Plot
					ax2 = subplot(1,3,3);
					hold(ax2, 'on');
                    D = colormap(ax2, 'copper');
					colormap(ax2, D);
					caxis(ax2, [0,1]);
					% f2 = figure;
					% ax3 = axes;
					% hold(ax3, 'on');
					
					% colormap(ax3, D);
					% set(ax3, 'ColorOrder',C);					
				else
					f2 = figure;
				end
				
				% set(ax2, 'ColorOrder',C);
				for ithresh = 1:nthresh
					if isnan(rsq(ithresh)) || nPoints(ithresh) == 2
						plot(ax2, yThresh(ithresh), 0, 'ko', 'LineWidth', 3);
						% plot(ax3, yThresh(ithresh), 0, 'o', 'LineWidth', 3);
					else
						cmapIdx = round(rsq(ithresh)*64);
						if cmapIdx > 64
							cmapIdx = 64;
						elseif cmapIdx == 0
							cmapIdx = 1;
						end
						plot(ax2, yThresh(ithresh), slope(ithresh), 'o', 'MarkerFaceColor', D(cmapIdx,:), 'MarkerEdgeColor', D(cmapIdx,:));
						% plot(ax2, yThresh(ithresh), rsq(ithresh), 'o', 'LineWidth', 3);
						% plot(ax3, yThresh(ithresh), slope(ithresh), 'o', 'LineWidth', 3);
					end
				end
				ylim(ax2,[0,1])
				title(ax2,'slope vs threshold')
				xlabel(ax2,'Y Threshold')
				ylabel(ax2,'slope')
				h = colorbar(ax2);
				ylabel(h, 'R^2')

				% ylim(ax3,[0,1])
				% title(ax3,'slope vs threshold')
				% xlabel(ax3,'Y Threshold')
				% ylabel(ax3,'slope')
				% 
				% 	Save the analysis results to the structure
				% 
				obj.Stat.hThresh(analysisNum).CTA2l.yThresh = yThresh;
				obj.Stat.hThresh(analysisNum).CTA2l.bins = bins;
				obj.Stat.hThresh(analysisNum).CTA2l.direction = direction;
				obj.Stat.hThresh(analysisNum).CTA2l.xingpos = xingpos;
				obj.Stat.hThresh(analysisNum).CTA2l.nbinsXing = nbinsXing;	
				obj.Stat.hThresh(analysisNum).CTA2l.xingtimes_s = xingtimes;
				obj.Stat.hThresh(analysisNum).CTA2l.actualMoveTime = actualMoveTime;
				obj.Stat.hThresh(analysisNum).CTA2l.rsq = rsq;	

			


			elseif strcmpi(Mode, 'singleTrial')
				warning('RBF: will use gfit as the default')
				% 
				% 	An easy way to do this is to do a custom binning with 1 trial per bin, then we can see everything with CTA2l method
				% 
				obj.getBinnedTimeseries(obj.GLM.gfit, 'singletrial', [], 30000);
				
				obj.horizontalThreshold('CTA2l', bins, nthresh, delay, direction, Plot, smoothing, useTS);

			end

		end

		function plotHThistogram(obj, threshnum)
			figure,
			ax1 = subplot(1,2,1);
			histogram(ax1, obj.Stat.hThresh(1).CTA2l.xingtimes_s(threshnum).thresh)
			title(ax1, ['Bins crossing Threshold #' num2str(threshnum) '/' num2str(numel(obj.Stat.hThresh(1).CTA2l.nbinsXing)) ' | nbins: ' num2str(obj.Stat.hThresh(1).CTA2l.nbinsXing(threshnum)), ' | R^2: ' num2str(obj.Stat.hThresh(1).CTA2l.rsq(threshnum))])
			xlabel(ax1, 'First Threshold Crossing Time')
			xlabel(ax1, '# of bins')
			xlim([0,17])
			ax2 = subplot(1,2,2);
			histogram(ax2, obj.Stat.hThresh(1).CTA2l.actualMoveTime(threshnum).thresh)
			title(ax2, ['Binned Actual First Lick Times'])
			xlabel(ax2, '# of bins')
			xlabel(ax2, 'First Lick Time')
			xlim([0,17])
		end

		function helloWorld(obj)
			disp('Hello World!')
		end

		function plotHistogram(obj, trials, Mode, stimMode)
			% 
			% 	Possible modes: flick and lick
			% 
			% 	
			disp('~~~~~~~~~~~~~~ Plotting Histogram ~~~~~~~~~~~~~~')
			if nargin < 3
				Mode = 'flick';
			end
			if nargin < 4
				stimMode = 0;
			end


			% 
			% 	trials = vector of trials to include in the histograam, ex: [1:10, 30, 100:1000]
			% 
			if nargin < 2 || isempty(trials)
				trials = obj.GLM.fLick_trial_num;
				disp('	Using all trials with a lick')
			else
				trials = trials;
				disp('	Using UI-specified trials')
			end

			if ~stimMode
				disp('	No optogenetics mode')
				% 
				% 	If UI doesn't specify trials to include, use all the trials with a 1st lick
				% 
				trials = trials;
			elseif stimMode 
				disp('	Trials divided by optogenetic stimulation or no stimulation')
				trials_stim = trials(ismember(trials, obj.GLM.stimTrials));
				trials_noStim = trials(ismember(trials, obj.GLM.noStimTrials));
			end
			

			if strcmpi(Mode, 'flick')
				disp('	Plotting only first licks wrt cue')
				% 
				% 	Put flicks in vector with nans for no-lick trials to make indexing easier
				% 	
				flick_reindexed = nan(obj.iv.num_trials,1);
				flick_reindexed(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s;
				if ~stimMode
					lick_times = flick_reindexed(trials) - obj.GLM.cue_s(trials);
					figure, histogram(lick_times)
				else
					lick_times_stim = flick_reindexed(trials_stim) - obj.GLM.cue_s(trials_stim);
					lick_times_noStim = flick_reindexed(trials_noStim) - obj.GLM.cue_s(trials_noStim);
					figure, hold on,
					histogram(lick_times_stim, 'DisplayName', 'Stimulated Trials')
					histogram(lick_times_noStim, 'DisplayName', 'No Stim Trials')	
				end
				title('Histogram of First Licks')
				ylabel('# of first licks')
				xlabel('s wrt cue')
			elseif strcmpi(Mode, 'lick')
				disp('	Plotting ALL licks wrt cue')
				if ~isfield(obj.GLM, 'all_ltbt_s')
					obj.GLM.all_ltbt_s = lick_times_by_trial_fx(obj.GLM.lick_s,obj.GLM.cue_s, obj.iv.total_time_/1000, obj.iv.num_trials);
				end
				if ~stimMode
					lick_times = obj.GLM.all_ltbt_s(obj.GLM.all_ltbt_s(1:end)>0);
					figure, histogram(lick_times)
				else
					lick_times_stim = obj.GLM.all_ltbt_s(trials_stim, :);
					lick_times_stim = lick_times_stim(lick_times_stim(1:end)>0);

					lick_times_noStim = obj.GLM.all_ltbt_s(trials_noStim, :);
					lick_times_noStim = lick_times_noStim(lick_times_noStim(1:end)>0);
					figure, hold on,
					histogram(lick_times_stim, 'DisplayName', 'Stimulated Trials')
					histogram(lick_times_noStim, 'DisplayName', 'No Stim Trials')	
				end
				title('Histogram of ALL Licks')
				ylabel('# of licks')
				xlabel('s wrt cue')
			else
				error('Must specify hxg mode')
			end
			legend('show')
		end




		
		function plotBinnedHistogram(obj, Mode, ref, rxnwin_s)
			% 
			% 	Mode: 	'hxg' 			= normalized histogram
			% 			'hxg-counts' 	= absolute numbers of first licks
			% 			'ecdf'			= ecdf of first
			% 			'raster'		= plots a raster
			% 
			% 	ref: 	'cue'			= cue reference event (standard)
			% 			'lick' 			
			% 			'lampOff'
			% 
			% 	rxnwin_s 				= 0.5 for hyb500, op500
			% 							= 0 for op0
			% 			Any licks within rxnwin_s of reference event will not be scored as "first"
			% 
            if nargin < 2
                Mode = 'hxg';
            end           
            if nargin < 3
            	ref = 'cue';
        	end     
        	if nargin < 4
        		rxnwin_s = 0;
    		end
			% 
			% 	Mode: 	'hxg': 			normalized histogram (probability)
			% 			'hxg-counts':	# of observations
			% 			'raster'
			% 
			obj.getBinnedLicks(ref, 5000, 5000, rxnwin_s);

			f = figure;
			if obj.iv.BingoMODE
				rb_ms = 5000;
				eot = 10000;
				target = 7500;
			else
				rb_ms = 3333;
				eot = 7000;
				target = 5000;
			end
			if strcmpi(Mode, 'raster')
				
				ax11raster = subplot(1, 1,  1, 'Parent', f);
				hold(ax11raster, 'on')
				% 
				% 	Plot raster of all licks with first licks overlaid
				% 
				plot(ax11raster, [0,0], [1,numel(obj.GLM.binnedLicks.refevents)],'r-', 'DisplayName', 'Cue')
				plot(ax11raster, [rb_ms/1000, rb_ms/1000], [1, obj.iv.num_trials],'k-', 'DisplayName', 'Reward Boundary')
				plot(ax11raster, [target/1000, target/1000], [1, obj.iv.num_trials],'r-', 'DisplayName', 'Target')
				plot(ax11raster, [eot/1000, eot/1000], [1, numel(obj.GLM.binnedLicks.refevents)],'k-', 'DisplayName', 'ITI Start')
				plot(ax11raster, [rxnwin_s, rxnwin_s], [1, numel(obj.GLM.binnedLicks.refevents)],'g-', 'DisplayName', 'Permitted Reaction Window')
				set(ax11raster,  'YDir','reverse')
				title(ax11raster, ['Lick Raster Aligned to ' obj.GLM.binnedLicks.ref])
				xlim(ax11raster, [0, obj.iv.total_time_/1000])
		        plot(ax11raster, obj.GLM.binnedLicks.f_lick_s_wrtref, 1:numel(obj.GLM.binnedLicks.refevents), 'mo', 'DisplayName', 'First Lick', 'MarkerFaceColor', 'm')
	    		ylim(ax11raster, [1, numel(obj.GLM.binnedLicks.refevents)])
		        
				ax11raster.XLabel.String = ['Time (s wrt ' obj.GLM.binnedLicks.ref ')'];
				ax11raster.YLabel.String = [obj.GLM.binnedLicks.ref 'Event #'];

				alllicktimes = obj.GLM.binnedLicks.lick_s;
			    
			    for iexc = obj.iv.exclusions_struct.Excluded_Trials
			    	all_lick_times_ex_swrtc{iexc} = [];
		    	end
				for itrial = 1:numel(obj.GLM.binnedLicks.refevents)
					plotpnts = alllicktimes{itrial};
					if ~isempty(plotpnts)
						plot(ax11raster, plotpnts, itrial.*ones(numel(plotpnts), 1),'k.')				
					end
				end
				
				yy = get(ax11raster, 'ylim');
				ylim(ax11raster, yy)
				% legend(ax11raster, 'show')
			elseif strcmpi(Mode, 'ecdf')
				
				[fff, xxx] = ecdf(obj.GLM.binnedLicks.f_lick_s_wrtref(obj.GLM.binnedLicks.f_lick_s_wrtref>0));

				ax3 = subplot(1, 1,  1, 'Parent', f);
				legend(ax3, 'show')
				plot(ax3, xxx, fff, 'LineWidth', 3, 'DisplayName', 'ecdf')
				hold(ax3, 'on')
				plot(ax3, [rxnwin_s, rxnwin_s], [0, 1],'g-', 'DisplayName', 'Permitted Reaction Window')
				plot(ax3, [eot/1000, eot/1000], [0, 1],'k-', 'DisplayName', 'ITI Start')
				plot(ax3, [target/1000, target/1000], [0, 1],'r-', 'DisplayName', 'Target')

				title(ax3, ['eCDF of First Licks wrt ' obj.GLM.binnedLicks.ref])
				xlim(ax3, [0, obj.iv.total_time_/1000])
				ylim(ax3, [0,1])
				ax3.XLabel.String = ['First Lick Time (s wrt ' obj.GLM.binnedLicks.ref ')'];
				ax3.YLabel.String = [obj.GLM.binnedLicks.ref ' Event #'];
			elseif strcmpi(Mode, 'hxg') || strcmpi(Mode, 'hxg-counts')
				ax1 = subplot(1, 3,  1, 'Parent', f);
				hold(ax1, 'on')
				ax2 = subplot(1, 3,  2, 'Parent', f);
				hold(ax2, 'on')
				ax3 = subplot(1, 3,  3, 'Parent', f);
				hold(ax3, 'on')

			
				histogram(ax1, obj.GLM.binnedLicks.f_lick_s_wrtref(~isnan(obj.GLM.binnedLicks.f_lick_s_wrtref)), 30, 'DisplayName', ['First Lick wrt ' obj.GLM.binnedLicks.ref], 'Normalization', 'cdf')
				yy = get(ax1, 'ylim');
				plot(ax1, [0, 0], [0,numel(obj.GLM.binnedLicks.refevents)],'r-', 'DisplayName', obj.GLM.binnedLicks.ref)
				plot(ax1, [rxnwin_s, rxnwin_s], [0, numel(obj.GLM.binnedLicks.refevents)],'g-', 'DisplayName', 'Permitted Reaction Window')
				ylim(ax1, yy)
				title(ax1, ['CDF of first licks Aligned to ' obj.GLM.binnedLicks.ref])
				xlim(ax1, [-.4, 17.5])
				ax1.XLabel.String = ['First Lick Time (s wrt ' obj.GLM.binnedLicks.ref ')'];
				ax1.YLabel.String = ['CDF of First Licks wrt ' obj.GLM.binnedLicks.ref 'Across Category'];

				
				if strcmpi(Mode, 'hxg')
					histogram(ax2, obj.GLM.binnedLicks.f_lick_s_wrtref(~isnan(obj.GLM.binnedLicks.f_lick_s_wrtref)), 30, 'DisplayName', ['First Lick wrt ' obj.GLM.binnedLicks.ref], 'Normalization', 'probability')
					ax2.YLabel.String = 'Percentage of First Licks Across Category';
				else
					histogram(ax2, obj.GLM.binnedLicks.f_lick_s_wrtref(~isnan(obj.GLM.binnedLicks.f_lick_s_wrtref)), 30, 'DisplayName', ['First Lick wrt ' obj.GLM.binnedLicks.ref])
					ax2.YLabel.String = '# of First Licks In Category';
				end
				yy = get(ax2, 'ylim');
				plot(ax2, [0, 0], [0,numel(obj.GLM.binnedLicks.refevents)],'r-', 'DisplayName', obj.GLM.binnedLicks.ref)
				plot(ax2, [rxnwin_s, rxnwin_s], [0, numel(obj.GLM.binnedLicks.refevents)],'g-', 'DisplayName', 'Permitted Reaction Window')
				ylim(ax2, yy)
				title(ax2, ['Histogram of first licks Aligned to ' obj.GLM.binnedLicks.ref])
				legend(ax2, 'show')
				xlim(ax2, [-.4, 17.5])
				ax2.XLabel.String = ['First Lick Time (s wrt ' obj.GLM.binnedLicks.ref ')'];



				warning('Hxg of all licks does not incorporate exclusions.')
				
				alllicktimes = cell2mat(obj.GLM.binnedLicks.lick_s');
				hold(ax3, 'on');
				histogram(ax3, alllicktimes, 30000, 'Normalization', 'probability')
				yy = get(ax3, 'ylim');
				plot(ax3, [rxnwin_s, rxnwin_s], [0, numel(obj.GLM.binnedLicks.refevents)],'g-', 'DisplayName', 'Permitted Reaction Window')
				plot(ax3, [0, 0], [0,numel(obj.GLM.binnedLicks.refevents)],'r-', 'DisplayName', obj.GLM.binnedLicks.ref)
				ylim(ax3, yy)
				title(ax3, ['ALL Licks wrt ' obj.GLM.binnedLicks.ref])
				xlim(ax3, [-5,18])
				ax3.XLabel.String = ['All Lick Times (s wrt ' obj.GLM.binnedLicks.ref ')'];
				ax3.YLabel.String = 'Percentage of Licks Across Session';
            end
		end

		function getBinnedLicks(obj, ref, s_b4, s_post, rxnwin_s)
			if nargin < 3
				s_b4 = 5000;
			end
			if nargin < 4
				s_post = 5000;
			end
			if nargin < 2
				ref = 'cue';
			end
			if nargin < 5
				rxnwin_s = 0;
			end
			obj.GLM.binnedLicks.ref = ref;
			obj.GLM.binnedLicks.s_b4 = s_b4;
			obj.GLM.binnedLicks.s_post = s_post;

			% pntrs
			cue = obj.GLM.cue_s;
			lick = obj.GLM.lick_s;
			lampOff = obj.GLM.lampOff_s;

			if strcmpi(ref, 'cue')
				refevents = cue;
			elseif strcmpi(ref, 'lick')
				refevents = lick;
			elseif strcmpi(ref, 'lampOff')
				refevents = lampOff;
			end
				
			for i_ref = 1:numel(refevents)
                lbe = find(lick > refevents(i_ref)-s_b4);
				lick_s_bt{i_ref} = lick(lbe(ismember(lbe, find(lick < refevents(i_ref) + s_post))));
                lick_s_bt_wrtref{i_ref} = lick_s_bt{i_ref} - refevents(i_ref);
                if ~isempty(lick_s_bt{i_ref}) && ~isempty(lick_s_bt{i_ref}(find(lick_s_bt{i_ref}>refevents(i_ref)+rxnwin_s, 1, 'first')))
                    f_lick_s_wrtref(i_ref, 1) = lick_s_bt{i_ref}(find(lick_s_bt{i_ref}>refevents(i_ref)+rxnwin_s, 1, 'first')) - refevents(i_ref);
                else
                    f_lick_s_wrtref(i_ref, 1) = nan;
                end
                if f_lick_s_wrtref(i_ref, 1) > obj.iv.total_time_/1000;
                	f_lick_s_wrtref(i_ref, 1) = nan;
            	end
                if ~isempty(lick_s_bt{i_ref})
                    assert(lick_s_bt{i_ref}(1) > refevents(i_ref)-s_b4 && lick_s_bt{i_ref}(end) < refevents(i_ref)+s_post);
                    assert(lick_s_bt_wrtref{i_ref}(1) > 0-s_b4 && lick_s_bt_wrtref{i_ref}(end) < s_post);
                end
			end

			obj.GLM.binnedLicks.lick_s = lick_s_bt_wrtref;
			obj.GLM.binnedLicks.f_lick_s_wrtref = f_lick_s_wrtref;
			obj.GLM.binnedLicks.refevents = refevents;
			obj.GLM.binnedLicks.rxnwin_s = rxnwin_s;
		end









		function verticalThreshold(obj, Mode, bins, nthresh, delay, Plot, useTS, smoothing)
			% 
			% 	Mode: 
			% 		'LTA2l': 		Will do in negative time wrt lick
			% 
			% 		'CTA2l': 	Will do wrt cue, but also can add a delay to ignore the initial bump, default zero
			% 					Note that if data is missing (like a bin has been passed), we'll just ignore that for now
			% 
			% 		'loTA2l'	A lights-off triggered average -- will just cut out the lamp off-lamp off periods. 
			% 					To be used with special binning procedure (overlap-loTA)
			% 
			% 	bins:
			% 		A list with the bins to be included in the analysis. Default is 'all'. Can specify as [1,4,9], etc. If specified bin is not in range, it is ignored
			% 
			% 	nthresh:
			% 		Number of thresholds to array, spaced evenly along the x-space from 0:binMin(end). Default is 1, right at the midpoint
			% 			You can supply specific thresholds to test, in ms
			% 
			% 	delay:
			% 		in ms, ignores a certain amount of time after the cue wrt the threshold crossing
			% 
			% 	Plot:
			% 		set to 0 or false to suppress plots
			% ---------------------------------------------------------------
			
			disp('Initializing vertical threshold model ---------------------')
			% 
			if nargin < 8
				smoothing = obj.Plot.smooth_kernel;
			end
			if nargin < 7
				useTS = false;
			end
			if nargin < 6 || ~islogical(Plot)
				disp('		Allowing plots')
				Plot = true;
			end
			if nargin < 5 || ~isnumeric(delay)
				disp('		Using 0ms delay for CTA2l (warning: only use int in ms for delay term)')
				delay = 0;
			else
				delay = round(delay);
				disp(['		Using ' num2str(delay) 'ms delay for CTA2l (warning: only use int in ms for delay term)'])
			end
			if nargin < 4 || numel(nthresh) == 1 && nthresh < 1
				disp('		Using only one threshold, at the midpoint of x-range.')
				nthresh = 1;
				nbreaks = 2;
			elseif numel(nthresh) > 1
				disp(['		UI determined thresholds to test. Testing  at: ' mat2str(nthresh) 'ms.'])
			else
				nthresh = round(nthresh);
				disp(['		Using ' num2str(nthresh) ' thresholds, evenly-spaced in x.'])
				nbreaks = nthresh + 1;
			end
			if nargin < 3 || strcmpi(bins, 'all')
				if useTS
					disp('		Using default bins: ''all'' for ts binned data')
					bins = 1:obj.ts.BinParams.nbins_CLTA;
				else
					disp('		Using default bins: ''all''')
					bins = 1:obj.BinParams.nbins_CLTA;
				end	
			elseif sum(ismember(bins, 1:obj.BinParams.nbins_CLTA)) < length(bins)
				warning(['An input bin is out of range. This will be ignored. There are only ', num2str(obj.BinParams.nbins_CLTA), ' CLTA bins total.'])
			end
			%	 
			% 	Determine the type of model - CTA2l or LTA
			% 
			if strcmpi(Mode, 'LTA2l')
				if useTS
					BinParams = obj.ts.BinParams;
				else
					BinParams = obj.BinParams;
				end					
				% 
				% 	Initilize a structure to keep track of the results of the analysis in .Stat
				% 
				if isfield(obj.Stat, 'vThresh') && isfield(obj.Stat.vThresh, 'LTA2l')
					analysisNum = length(obj.Stat.vThresh(end).LTA2l) + 1;
					obj.Stat.vThresh(analysisNum).LTA2l = {};
				else
					analysisNum = 1;
					obj.Stat.vThresh(analysisNum).LTA2l = {};
				end
				% 
				% 	For each bin, find the crossing Y-position
				% 		Note that if the cue hasn't happened yet, we shouldn't consider this bin. So need to effectively trim 
				% 		each bin by the earliest possible cue position.
				% 
				binTimeMin = {BinParams.s(bins).CLTA_Min};
                binPosMin = cellfun(@(x) find(obj.Plot.LTA.xticks.s >= -x, 1, 'first'), binTimeMin, 'UniformOutput', 0);
				xmins = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), binTimeMin, 'UniformOutput', 0);
				xmin = min(cell2mat(xmins));
				xmax = find(obj.Plot.LTA.xticks.s > 0, 1, 'first');
				% 
				% 	Trim the bins for use in analysis
				% 
				smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), {BinnedData.LTA(bins).All}, 'UniformOutput', 0)); 
				trimmedSets = (cellfun(@(ibin, xm) obj.nanTrim(ibin, 1, xm-1), smoothedSets, binPosMin(bins), 'UniformOutput', 0)); 
				% 
				% 	For plotting ranges:
				%
				yMin = nanmin(cellfun(@(x,y) nanmin(x(xmins{y}:xmax)), smoothedSets, num2cell(1:numel(bins))));
				yMax = nanmax(cellfun(@(x,y) nanmax(x(xmins{y}:xmax)), smoothedSets, num2cell(1:numel(bins))));
				% 
				% 	Find the range over which (in y-axis) to test thresholds and thresholds to test
				% 
				if numel(nthresh) == 1	
					xspan = xmax-xmin;              % in ms wrt cue
					xtix = xspan/nbreaks;
					xPos = [xmin:xtix:xmax];		% this includes the min and max, which there's no point in testing
					xThresh = xPos(2:end-1);        % this only includes the thresholds that will get tested
                    xThresh = xThresh * obj.Plot.samples_per_ms;    % in ms, then samples
                else
                    if find(nthresh) > 1000
    					xThresh = nthresh/1000;         % enter the thresh times in ms wrt lick
                    else
                        xThresh = nthresh;
                    end
                    xThresh = find(obj.Plot.LTA.xticks.s >= xThresh, 1, 'first'); % now in positions wrt LTA array
					nthresh = numel(nthresh);			
                end
				% 
				% 	Collect the crossing position in y-axis for each bin
				% 
				xingY = {};
				rsq = nan(nthresh, 1);
				% 
				if Plot
					f1 = figure; 
					% 
					% 	Plot the smoothed curves with thresholds on the
					% 	left (looks good 10/7/18)
					% 
					C = linspecer(numel(bins)+nthresh); 
		            axes('NextPlot','replacechildren', 'ColorOrder',C);
		            ax0 = subplot(1,3,1);
	            	obj.plot('LTA2l', bins, true);
	            	hold on
	            	cellfun(@(xt,idx) plot([obj.Plot.LTA.xticks.s(round(xt)),obj.Plot.LTA.xticks.s(round(xt))], [yMin,yMax], 'DisplayName', ['Threshold #' num2str(idx), ' ', num2str(xt)]), num2cell(xThresh), num2cell(1:nthresh));
	            	legend('show')
                    ylim([yMin, yMax])
					% 
					% 	The middle pannel is for the regression
					% 
		            C = linspecer(2*nthresh); 
		            axes('NextPlot','replacechildren', 'ColorOrder',C);
		            ax1 = subplot(1,3,2);
	            	plot(ax1, [0,cell2mat(binTimeMin(bins(end)))], -[0,cell2mat(binTimeMin(bins(end)))], 'k-', 'DisplayName', 'meridian')
	            	xlabel('Earliest Lick Time (s)')
					ylabel('Height at Threshold')
	            	hold on
                    ylim([yMin, yMax])
				end
				for ithresh = 1:nthresh
					% 
					% 	Find the height at threshold for each bin
					%   Note that if the cue hasn't happened yet, we should ignore this bin:
					% ***** NOTE: then exclude this using onesMode = true in zero2nan
					% 
					xingY(ithresh).thresh = cellfun(@(ibin) nansum([ibin(round(xThresh(ithresh))), nan]), trimmedSets, 'UniformOutput', 0);
					xingY(ithresh).thresh = cell2mat(cellfun(@(x) obj.zero2nan(x, true), xingY(ithresh).thresh, 'UniformOutput', 0));
					% 
					%	Now, for each threshold, we will regress the crossing position-Y for each bin against the right** edge of bin
					% 
					[b, dev, stats] = glmfit(cell2mat(binTimeMin(bins)),xingY(ithresh).thresh);
					yfit = glmval(b,cell2mat(binTimeMin(bins)), 'identity');
					[rsq(ithresh), ~] = obj.rSquared(xingY(ithresh).thresh', yfit);
					if Plot
						plot(ax1, cell2mat(binTimeMin(bins)),yfit,'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh))])
						plot(ax1, cell2mat(binTimeMin(bins)),xingY(ithresh).thresh, 'o', 'LineWidth', 2, 'DisplayName', ['Threshold #', num2str(ithresh), ' x=' num2str(obj.Plot.LTA.xticks.s(round(xThresh(ithresh))))])
					end
					obj.Stat.vThresh(analysisNum).LTA2l.b{ithresh} = b;
					obj.Stat.vThresh(analysisNum).LTA2l.dev{ithresh} = dev;
					obj.Stat.vThresh(analysisNum).LTA2l.stats(ithresh) = stats;
				end
				legend('show')
				title('Curve Height (Y) at Threshold Time')
				% 
				%	Finally, plot the R^2 vs threshold 
				% 
				if Plot
					ax2 = subplot(1,3,3);
				else
					f2 = figure;
				end
				plot(ax2, obj.Plot.LTA.xticks.s(round(xThresh)), rsq, 'o', 'LineWidth', 3);
				ylim([0,1])
				title('R^2 vs threshold')
				xlabel('Threshold Time wrt Lick (s)')
				ylabel('R^2')
				% 
				% 	Save the analysis results to the structure
				% 
				obj.Stat.vThresh(analysisNum).LTA2l.xThresh = xThresh;
				obj.Stat.vThresh(analysisNum).LTA2l.bins = bins;
				obj.Stat.vThresh(analysisNum).LTA2l.xingY = xingY;
				obj.Stat.vThresh(analysisNum).LTA2l.rsq = rsq;


			elseif strcmpi(Mode, 'LTA')
				if useTS
					BinParams = obj.ts.BinParams;
				else
					BinParams = obj.BinParams;
				end
				% --------------------------------------------------------------------
				%  This simpler model ignores the cue position and considers all times
				% --------------------------------------------------------------------
				% 
				% 	Initilize a structure to keep track of the results of the analysis in .Stat
				% 
				if isfield(obj.Stat, 'vThresh') && isfield(obj.Stat.vThresh, 'LTA')
					analysisNum = length(obj.Stat.vThresh(end).LTA) + 1;
					obj.Stat.vThresh(analysisNum).LTA = {};
				else
					analysisNum = 1;
					obj.Stat.vThresh(analysisNum).LTA = {};
				end
				% 
				% 	For each bin, find the crossing Y-position
				% 		Note that if the cue hasn't happened yet, we shouldn't consider this bin. So need to effectively trim 
				% 		each bin by the earliest possible cue position.
				% 
				binTimeMin = {obj.BinParams.s.CLTA_Min};
                binPosMin = cellfun(@(x) find(obj.Plot.LTA.xticks.s >= -x, 1, 'first'), binTimeMin, 'UniformOutput', 0);
				xmins = cellfun(@(x) find(obj.Plot.LTA.xticks.s > -x, 1, 'first'), binTimeMin(bins), 'UniformOutput', 0);
				xmin = min(cell2mat(xmins));
				xmax = find(obj.Plot.LTA.xticks.s > 0, 1, 'first');
				% 
				% 	Trim the bins for use in analysis
				% 
				smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), {obj.BinnedData.LTA(bins).All}, 'UniformOutput', 0)); 
				% 
				% 	For plotting ranges:
				%
				yMin = nanmin(cellfun(@(x,y) nanmin(x(xmins{y}:xmax)), smoothedSets, num2cell(1:numel(bins))));
				yMax = nanmax(cellfun(@(x,y) nanmax(x(xmins{y}:xmax)), smoothedSets, num2cell(1:numel(bins))));
				% 
				% 	Find the range over which (in y-axis) to test thresholds and thresholds to test
				% 
				if numel(nthresh) == 1	
					xspan = xmax-xmin;              % in ms wrt cue
					xtix = xspan/nbreaks;
					xPos = [xmin:xtix:xmax];		% this includes the min and max, which there's no point in testing
					xThresh = xPos(2:end-1);        % this only includes the thresholds that will get tested
                    xThresh = xThresh * obj.Plot.samples_per_ms;    % in ms, then samples
                else
                    if find(nthresh) > 1000
    					xThresh = nthresh/1000;         % enter the thresh times in ms wrt lick
                    else
                        xThresh = nthresh;
                    end
                    xThresh = find(obj.Plot.LTA.xticks.s >= xThresh, 1, 'first'); % now in positions wrt LTA array
					nthresh = numel(nthresh);			
                end
				% 
				% 	Collect the crossing position in y-axis for each bin
				% 
				xingY = {};
				rsq = nan(nthresh, 1);
				% 
				if Plot
					f1 = figure; 
					% 
					% 	Plot the smoothed curves with thresholds on the
					% 	left (looks good 10/7/18)
					% 
					C = linspecer(numel(bins)+nthresh); 
		            axes('NextPlot','replacechildren', 'ColorOrder',C);
		            ax0 = subplot(1,3,1);
	            	obj.plot('LTA', bins, true);
	            	hold on
	            	cellfun(@(xt,idx) plot([obj.Plot.LTA.xticks.s(round(xt)),obj.Plot.LTA.xticks.s(round(xt))], [yMin,yMax], 'DisplayName', ['Threshold #' num2str(idx), ' ', num2str(xt)]), num2cell(xThresh), num2cell(1:nthresh));
	            	legend('show')
                    ylim([yMin, yMax])
					% 
					% 	The middle pannel is for the regression
					% 
		            C = linspecer(2*nthresh); 
		            axes('NextPlot','replacechildren', 'ColorOrder',C);
		            ax1 = subplot(1,3,2);
	            	plot(ax1, [0,cell2mat(binTimeMin(bins(end)))], -[0,cell2mat(binTimeMin(bins(end)))], 'k-', 'DisplayName', 'meridian')
	            	xlabel('Earliest Lick Time (s)')
					ylabel('Height at Threshold')
	            	hold on
                    ylim([yMin, yMax])
				end
				for ithresh = 1:nthresh
					% 
					% 	Find the height at threshold for each bin
					%   Note that if the cue hasn't happened yet, we should ignore this bin:
					% ***** NOTE: then exclude this using onesMode = true in zero2nan
					% 
					xingY(ithresh).thresh = cellfun(@(ibin) nansum([ibin(round(xThresh(ithresh))), nan]), smoothedSets, 'UniformOutput', 0);
					xingY(ithresh).thresh = cell2mat(cellfun(@(x) obj.zero2nan(x, true), xingY(ithresh).thresh, 'UniformOutput', 0));
					% 
					%	Now, for each threshold, we will regress the crossing position-Y for each bin against the right** edge of bin
					% 
					[b, dev, stats] = glmfit(cell2mat(binTimeMin(bins)),xingY(ithresh).thresh);
					yfit = glmval(b,cell2mat(binTimeMin(bins)), 'identity');
					[rsq(ithresh), ~] = obj.rSquared(xingY(ithresh).thresh', yfit);
					if Plot
						plot(ax1, cell2mat(binTimeMin(bins)),yfit,'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh))])
						plot(ax1, cell2mat(binTimeMin(bins)),xingY(ithresh).thresh, 'o', 'LineWidth', 2, 'DisplayName', ['Threshold #', num2str(ithresh), ' x=' num2str(obj.Plot.LTA.xticks.s(round(xThresh(ithresh))))])
					end
					obj.Stat.vThresh(analysisNum).LTA.b{ithresh} = b;
					obj.Stat.vThresh(analysisNum).LTA.dev{ithresh} = dev;
					obj.Stat.vThresh(analysisNum).LTA.stats(ithresh) = stats;
				end
				legend('show')
				title('Curve Height (Y) at Threshold Time')
				% 
				%	Finally, plot the R^2 vs threshold 
				% 
				if Plot
					ax2 = subplot(1,3,3);
				else
					f2 = figure;
				end
				plot(ax2, obj.Plot.LTA.xticks.s(round(xThresh)), rsq, 'o', 'LineWidth', 3);
				ylim([0,1])
				title('R^2 vs threshold')
				xlabel('Threshold Time wrt Lick (s)')
				ylabel('R^2')
				% 
				% 	Save the analysis results to the structure
				% 
				obj.Stat.vThresh(analysisNum).LTA.xThresh = xThresh;
				obj.Stat.vThresh(analysisNum).LTA.bins = bins;
				obj.Stat.vThresh(analysisNum).LTA.xingY = xingY;
				obj.Stat.vThresh(analysisNum).LTA.rsq = rsq;

			elseif strcmpi(Mode, 'CTA2l')
				if useTS
					% verified 1/22/19
					BinParams = obj.ts.BinParams;
					xticks = obj.ts.Plot.CTA.xticks.s;
					BinnedData.CTA = obj.ts.BinnedData.CTA;
					CTAsize = size(xticks, 2);
					first_post_cue_position = find(xticks == 1);
				else
					% verified 1/22/19
					BinParams = obj.BinParams;
					xticks = obj.Plot.CTA.xticks.s;
					BinnedData.CTA = obj.BinnedData.CTA;
					CTAsize = obj.Plot.CTA.size;
					first_post_cue_position = obj.Plot.first_post_cue_position;
				end
				% 
				% 	Initilize a structure to keep track of the results of the analysis in .Stat
				% 
				if isfield(obj.Stat, 'vThresh') && isfield(obj.Stat.vThresh, 'CTA2l')
					analysisNum = length(obj.Stat.vThresh(end).CTA2l) + 1;
					obj.Stat.vThresh(analysisNum).CTA2l = {};
				else
					analysisNum = 1;
					obj.Stat.vThresh(analysisNum).CTA2l = {};
                end
				% 
				% 	For each bin, find the crossing time in x (s)
				% 
				% 		For each bin, we have a different range of xmin times to consider - obviously doesn't make sense to look at times before the cue
				% 		THUS only look until the right side of the bin, which is the furthest back time without pre-cue times for that bin
				% 
				binTimeMin = {BinParams.s(bins).CLTA_Min};
				xmaxs = cellfun(@(x) find(xticks > x, 1, 'first'), binTimeMin);
				xmin = find(xticks >= 0 + delay/1000, 1, 'first');
                %
                %   Exclude non-qualifying bins
                %
                bins(xmaxs < xmin) = [];
                xmaxs(xmaxs < xmin) = [];
                xmax = max(xmaxs);
                binTimeMin = {BinParams.s(bins).CLTA_Min};
                % 
				smoothedSets = (cellfun(@(x) obj.smooth(x, smoothing), BinnedData.CTA(bins), 'UniformOutput', 0));
				% 
				% 	Trim off the times after lick
				% 
				smoothedSets = cellfun(@(x,y) obj.nanTrim(x, y, CTAsize), smoothedSets, num2cell(xmaxs), 'UniformOutput', 0);
				% 
				% 	Get range for plot
				% 
				yMin = nanmin(cell2mat(cellfun(@(x,y) nanmin(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
				yMax = nanmax(cell2mat(cellfun(@(x,y) nanmax(x(xmin:xmaxs(y))), smoothedSets, num2cell([1:numel(bins)]), 'UniformOutput', 0)));
				% 
				% 	Find the range over which (in y-axis) to test thresholds and thresholds to test
				%
				if numel(nthresh) == 1
					xspan = xmax-xmin;
					xtix = xspan/nbreaks;
					xPos = [xmin:xtix:xmax];		% this includes the min and max, which there's no point in testing
					xThresh = xPos(2:end-1); 		% this only has the thresholds which will be tested
				else
					xThresh = nthresh;
					if ~isempty(find(xThresh > 1000, 1, 'first')) || ~isempty(find(xThresh < -1000, 1, 'first'))
						xThresh = xThresh * obj.Plot.samples_per_ms;
					else
						xThresh = xThresh * obj.Plot.samples_per_ms * 1000;
					end
					prepos = find(xThresh < 0);
					if numel(prepos) > 0
						xThresh(prepos) = cellfun(@(x) first_post_cue_position + xThresh(x), num2cell(prepos));
					end
					zeropos = find(xThresh == 0);
					if ~isempty(zeropos)
						xThresh(zeropos) = first_post_cue_position - 1;
					end
					nthresh = numel(nthresh);
				end
				% 
				% 	Collect the crossing height
				% 
				xingY = {};

				rsq = nan(nthresh, 1);
				if Plot
					f1 = figure; 
					% 
					% 	Plot the smoothed curves with thresholds on the
					% 	left (looks good 10/7/18)
					% 
		            ax0 = subplot(1,2,1);
		            if useTS
						obj.plot('CTA2l', bins, true, smoothing, 'last-to-first', 1)
	            	else
		            	obj.plot('CTA2l', bins, true);
            		end
	            	hold on
	            	blacks = zeros(numel(bins)+1, 3);
	            	% C = linspecer(nthresh); 
	            	C = colormap(copper);
	            	cmIdxs = ceil(((1:nthresh)./nthresh)*64);
	            	C = C(cmIdxs,:);
		            set(ax0, 'ColorOrder',[C]);
	            	cellfun(@(x,y) plot([xticks(round(x)),xticks(round(x))], [yMin, yMax], 'DisplayName', ['Threshold #' num2str(y), ' ', num2str(xticks(round(xThresh(y))))]), num2cell(xThresh), num2cell(1:nthresh));
	            	legend('show')
	            	ylim([yMin,yMax]);
	            	xlim([xticks(1), cell2mat(binTimeMin(end))])
					% 
					% 	The middle pannel is for the regression
					% 
		            ax1 = subplot(2,2,2);
	            	plot(ax1, [0,cell2mat(binTimeMin(end))], [0,cell2mat(binTimeMin(end))], 'k-', 'DisplayName', 'meridian')
	            	C2 = reshape([C,C]',3,2*nthresh)';
	            	set(ax1, 'ColorOrder',C2); 
	            	xlabel(ax1, 'Lick Time wrt Cue (s)')
					ylabel(ax1, 'Threshold Crossing Height (dF/F)')
	            	hold on
				end
				ymn = nanmedian(smoothedSets{1});
				ymx = nanmedian(smoothedSets{1});
				for ithresh = 1:nthresh
					% 
					% 	Get height of curve at X-thresh
					% ***** NOTE: if curve is already ended at X-thresh, then exclude this using onesMode = true in zero2nan
					% 
					xingY(ithresh).thresh = cellfun(@(x) x(round(xThresh(ithresh))), smoothedSets(1:numel(bins)), 'UniformOutput', 0);
					xingY(ithresh).thresh = cell2mat(cellfun(@(x) obj.zero2nan(x, true), xingY(ithresh).thresh, 'UniformOutput', 0));
					% 
					binsThisThresh = ~isnan(xingY(ithresh).thresh);
					nbinsThisThresh(ithresh) = numel(find(binsThisThresh));
					xingY(ithresh).thresh = xingY(ithresh).thresh(binsThisThresh);
					% 
					[b, dev, stats] = glmfit(cell2mat(binTimeMin(binsThisThresh)),xingY(ithresh).thresh);
					p(ithresh) = stats.p(2);
					yfit = glmval(b,cell2mat(binTimeMin(binsThisThresh)), 'identity');
					[rsq(ithresh), ~] = obj.rSquared(xingY(ithresh).thresh', yfit);
					% [r(ithresh), rsqTest(ithresh)] = obj.rCorrCoeff(xingY(ithresh).thresh', yfit);
					% if round(rsq(ithresh),3) ~= round(rsqTest(ithresh),3)
					% 	disp('** r^2 measures don''t match! **')
					% 	disp(['	rsq_AH = ' num2str(rsq(ithresh))])
					% 	disp(['	rsq_mat = ' num2str(rsqTest(ithresh))])
					% 	disp('--')
					% end
					xx = cell2mat(binTimeMin(binsThisThresh));
					x1 = xx(1);
					x2 = xx(end);

					slope(ithresh) = (yfit(end) - yfit(1))/(x2-x1);
					if numel(yfit) > 1
						if slope(ithresh) > 0
							r(ithresh) = 1;
						elseif slope(ithresh) < 0
							r(ithresh) = -1;
						else
							r(ithresh) = nan;
						end
					else
						r(ithresh) = nan;
					end
							
					if Plot
						if nbinsThisThresh > 2
							plot(ax1, cell2mat(binTimeMin(binsThisThresh)),yfit,'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh)) ' | n=' num2str(nbinsThisThresh(ithresh))])
						else
							plot(ax1, [0.000001, 0.000002],[0.000001, 0.000002],'-','LineWidth',2, 'DisplayName', ['Threshold #', num2str(ithresh), ' R^2:' num2str(rsq(ithresh)) ' | n=' num2str(nbinsThisThresh(ithresh))])
						end
						scatter3(ax1, cell2mat(binTimeMin(binsThisThresh)),xingY(ithresh).thresh, bins(binsThisThresh), 'o', 'LineWidth', 2, 'DisplayName', ['Threshold #', num2str(ithresh), ' x=' num2str(xticks(round(xThresh(ithresh))))])
						ymn = (min(xingY(ithresh).thresh) < ymn)*min(xingY(ithresh).thresh) + (ymn < min(xingY(ithresh).thresh))*ymn;
						ymx = (max(xingY(ithresh).thresh) > ymx)*max(xingY(ithresh).thresh) + (ymx > max(xingY(ithresh).thresh))*ymx;
						ylim([ymn, ymx])
					end
					obj.Stat.vThresh(analysisNum).CTA2l.b{ithresh} = b;
					obj.Stat.vThresh(analysisNum).CTA2l.dev{ithresh} = dev;
					obj.Stat.vThresh(analysisNum).CTA2l.stats(ithresh) = stats;
				end
				legend(ax1, 'show')
				title(ax1, ['Threshold Y-position vs Lick Time DELAY=', num2str(delay), 'ms'])
				zlabel(ax1, 'bin #')
				h = colorbar(ax1);
				ylabel(h, 'X-slice (s wrt cue)')
            	caxis(ax1, [xticks(round(xThresh(1))), xticks(round(xThresh(end)))])
				% 
				%	Finally, plot the R^2 vs threshold 
				% 
				if Plot
					ax2 = subplot(2,2,4);
					% C = linspecer(nthresh);
		            set(ax2, 'ColorOrder',C);
                    hold(ax2, 'on');
				else
					f2 = figure;
					% C = linspecer(nthresh);
		            axes('NextPlot','replacechildren', 'ColorOrder',C);
                    hold on;
				end
                f3 = figure;
                % C = linspecer(nthresh);
	            ax3 = subplot(1,2,1);
	            set(ax3, 'ColorOrder',C);
                hold(ax3, 'on');
                xlabel('time wrt cue (s)')
                ylabel('slope of fit correlation at x-slice')
                ax4 = subplot(1,2,2);
                set(ax4, 'ColorOrder',C);
                hold(ax4, 'on');
                xlabel('time wrt cue (s)')
                ylabel('p-value of fit slope at x-slice')
				for ithresh = 1:nthresh
					if p(ithresh) < 0.025
						if isnan(rsq(ithresh)) || nbinsThisThresh(ithresh) == 2 || isinf(rsq(ithresh))
							if r(ithresh) > 0
								plot(ax2, xticks(round(xThresh(ithresh))), 0, 'o', 'Markersize', 8, 'linewidth', 3);
							elseif r(ithresh) < 0
								plot(ax2, xticks(round(xThresh(ithresh))), 0, 'x', 'Markersize', 8, 'linewidth', 3);
							else
								plot(ax2, xticks(round(xThresh(ithresh))), 0, '.', 'Markersize', 8, 'linewidth', 3);
							end
						else
							if r(ithresh) > 0
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), 'o', 'Markersize', 8, 'linewidth', 3);
							elseif r(ithresh) < 0
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), 'x', 'Markersize', 8, 'linewidth', 3);
							else
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), '.', 'Markersize', 8, 'linewidth', 3);
							end
						end
						if r(ithresh) > 0
							plot(ax3, xticks(round(xThresh(ithresh))), slope(ithresh), 'o', 'Markersize', 30, 'linewidth', 3)
							plot(ax4, xticks(round(xThresh(ithresh))), p(ithresh), 'o', 'Markersize', 30, 'linewidth', 3)
						elseif r(ithresh) < 0
							plot(ax3, xticks(round(xThresh(ithresh))), slope(ithresh), 'x', 'Markersize', 30, 'linewidth', 3)
							plot(ax4, xticks(round(xThresh(ithresh))), p(ithresh), 'x', 'Markersize', 30, 'linewidth', 3)
						else
							plot(ax3, xticks(round(xThresh(ithresh))), slope(ithresh), '.', 'Markersize', 30, 'linewidth', 3)
							plot(ax4, xticks(round(xThresh(ithresh))), p(ithresh), '.', 'Markersize', 30, 'linewidth', 3)
						end
					elseif p(ithresh) < 0.05
						if isnan(rsq(ithresh)) || nbinsThisThresh(ithresh) == 2 || isinf(rsq(ithresh))
							if r(ithresh) > 0
								plot(ax2, xticks(round(xThresh(ithresh))), 0, 'o', 'Markersize', 6, 'linewidth', 2);
							elseif r(ithresh) < 0
								plot(ax2, xticks(round(xThresh(ithresh))), 0, 'x', 'Markersize', 6, 'linewidth', 2);
							else
								plot(ax2, xticks(round(xThresh(ithresh))), 0, '.', 'Markersize', 6, 'linewidth', 2);
							end
						else
							if r(ithresh) > 0
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), 'o', 'Markersize', 6, 'linewidth', 2);
							elseif r(ithresh) < 0
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), 'x', 'Markersize', 6, 'linewidth', 2);
							else
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), '.', 'Markersize', 6, 'linewidth', 2);
							end
						end
						if r(ithresh) > 0
							plot(ax3, xticks(round(xThresh(ithresh))), slope(ithresh), 'o', 'Markersize', 15, 'linewidth', 3)
							plot(ax4, xticks(round(xThresh(ithresh))), p(ithresh), 'o', 'Markersize', 15, 'linewidth', 3)
						elseif r(ithresh) < 0
							plot(ax3, xticks(round(xThresh(ithresh))), slope(ithresh), 'x', 'Markersize', 15, 'linewidth', 3)
							plot(ax4, xticks(round(xThresh(ithresh))), p(ithresh), 'x', 'Markersize', 15, 'linewidth', 3)
						else
							plot(ax3, xticks(round(xThresh(ithresh))), slope(ithresh), '.', 'Markersize', 15, 'linewidth', 3)
							plot(ax4, xticks(round(xThresh(ithresh))), p(ithresh), '.', 'Markersize', 15, 'linewidth', 3)
						end
					else
						if isnan(rsq(ithresh)) || nbinsThisThresh(ithresh) == 2 || isinf(rsq(ithresh))
							if r(ithresh) > 0
								plot(ax2, xticks(round(xThresh(ithresh))), 0, 'o', 'Markersize', 5, 'linewidth', 1);
							elseif r(ithresh) < 0
								plot(ax2, xticks(round(xThresh(ithresh))), 0, 'x', 'Markersize', 5, 'linewidth', 1);
							else
								plot(ax2, xticks(round(xThresh(ithresh))), 0, '.', 'Markersize', 5, 'linewidth', 1);
							end
						else
							if r(ithresh) > 0
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), 'o', 'Markersize', 5, 'linewidth', 1);
							elseif r(ithresh) < 0
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), 'x', 'Markersize', 5, 'linewidth', 1);
							else
								plot(ax2, xticks(round(xThresh(ithresh))), rsq(ithresh), '.', 'Markersize', 5, 'linewidth', 1);
							end
						end
						plot(ax3, xticks(round(xThresh(ithresh))), slope(ithresh), '.', 'Markersize', 10)
						plot(ax4, xticks(round(xThresh(ithresh))), p(ithresh), '.', 'Markersize', 10)
					end
				end
				
                if delay < 0
                    tlines = -1.*fliplr([0:obj.iv.total_time_/1000:abs(delay)/1000]);
                else
                    tlines = [0:obj.iv.total_time_/1000:delay/1000];
                end
				% tlines = reshape([tlines;tlines],1,2*numel(tlines));
				for tlinesIdx = 1:numel(tlines)
					plot(ax3, [tlines(tlinesIdx),tlines(tlinesIdx)], [min(slope), max(slope)], 'k-')
					plot(ax4, [tlines(tlinesIdx),tlines(tlinesIdx)], [min(p), max(p)], 'k-')
				end
				
				ylim(ax2, [0,1])
				title(ax2, 'R^2 vs threshold')
				xlabel(ax2, 'X Threshold (s wrt cue)')
				ylabel(ax2, 'R^2')

				
				

				% 
				% 	Save the analysis results to the structure
				% 
				obj.Stat.vThresh(analysisNum).CTA2l.yThresh = xThresh;
				obj.Stat.vThresh(analysisNum).CTA2l.bins = bins;
				obj.Stat.vThresh(analysisNum).CTA2l.xingY = xingY;
				obj.Stat.vThresh(analysisNum).CTA2l.rsq = rsq;
			end

		end


		function stats = lickTimeVSLampOffInterval(obj)
			% 
			%	Check the object has the appropriate data-style (needs to contain gfit) 
			% 
			if obj.GLM.Mode ~= true
				error('Need GLM-compatible statsobject from version 2.x and up. (10/11/18)')
			end
			% 
			% 	Get lightsOff positions if doesn't exist
			% 
			% if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos,'lampOff')
			obj.GLM.flush = {};	
			obj.GLM.pos.lampOff = obj.getXPositionsWRTgfit(obj.GLM.lampOff_s);
			% end
			% 
			% 	Get LO-interval from LampOff to Cue-On if haven't done yet
			% 
			% if ~isfield(obj.GLM, 'LOI_s')
			obj.GLM.LOI_s = obj.GLM.cue_s - obj.GLM.lampOff_s;
			% end
			% 
			% 	Make trial-matched lick vector -- represent no-lick as 17
			% 
			% if ~isfield(obj.GLM, 'tm_lick_wrtCue_s')
				obj.GLM.tm_lick_wrtCue_s = nan*ones(numel(obj.GLM.cue_s), 1);
				obj.GLM.tm_lick_wrtCue_s(obj.GLM.fLick_trial_num) =  obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
			% end
			% 
			% 	Plot the LOI vs flick
			% 
			stagger = rand(numel(obj.GLM.tm_lick_wrtCue_s));
			figure,
			subplot(1,2,1)
			plot(obj.GLM.LOI_s, obj.GLM.tm_lick_wrtCue_s, 'o')
			xlabel('light-off interval time (s)')
			ylabel('first-lick time wrt cue (s)')
			% 
			% 	Regression of LOI vs flick
			% 			
			[b, dev, stats] = glmfit(obj.GLM.LOI_s(obj.GLM.tm_lick_wrtCue_s<7), obj.GLM.tm_lick_wrtCue_s(obj.GLM.tm_lick_wrtCue_s<7));
			rsq = 1 - sum(stats.resid.^2) / sum((obj.GLM.tm_lick_wrtCue_s(obj.GLM.tm_lick_wrtCue_s<7)-nanmean(obj.GLM.tm_lick_wrtCue_s(obj.GLM.tm_lick_wrtCue_s<7))).^2);
			disp(['slope & offset = ', mat2str(b)])
			disp(['r^2 = ', num2str(rsq)])
			yfit = glmval(b, [0.4:0.1:1.5], 'identity');

			subplot(1,2,2)
			plot(obj.GLM.LOI_s(obj.GLM.tm_lick_wrtCue_s<7), obj.GLM.tm_lick_wrtCue_s(obj.GLM.tm_lick_wrtCue_s<7), 'o')
			hold on
			plot([0.4:0.1:1.5],yfit)
			xlabel('light-off interval time (s)')
			ylabel('first-lick time wrt cue (s)')
			% 
			% 	Find the no-lick trials
			% 
			nolickTrials = find(isnan(obj.GLM.tm_lick_wrtCue_s));
			figure,
			subplot(2,2,1)
			histogram(obj.GLM.LOI_s(nolickTrials),2)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with no-lick')
			subplot(2,2,2)
			histogram(obj.GLM.LOI_s(nolickTrials),4)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with no-lick')
			subplot(2,2,3)
			histogram(obj.GLM.LOI_s(nolickTrials),8)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with no-lick')
			subplot(2,2,4)
			histogram(obj.GLM.LOI_s(nolickTrials), 16)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with no-lick')
			% 
			% 	Now, divide the whole session into 3 parts:
			% 
			ntrials = numel(obj.GLM.LOI_s);
			ntrials_per_bin = floor(ntrials / 3);
			figure,
			disp(' ')
			disp('session binned into 3 blocks')
			for ibin = 1:3
				disp(' ')
				disp(['bin #', num2str(ibin)])
				y = obj.GLM.tm_lick_wrtCue_s(1+(ibin-1)*ntrials_per_bin:ibin*ntrials_per_bin);
				y_7 = y(y<7);
				y_norxn = y_7(y_7>0.7);
				X = obj.GLM.LOI_s(1+(ibin-1)*ntrials_per_bin:ibin*ntrials_per_bin);
				X_7 = X(y<7);
				X_norxn = X_7(y_7>0.7);
				subplot(3,3,1+3*(ibin-1))
				plot(X, y, 'o')
				xlabel('light-off interval time (s)')
				ylabel('first-lick time wrt cue (s)')
				% 
				% 	Regression of LOI vs flick
				% 			
				[b, dev, stats] = glmfit(X_7, y_7);
				rsq = 1 - sum(stats.resid.^2) / sum((y_7-nanmean(y_7)).^2);
				disp('Up to trial end.......')
				disp(['offset & slope = ', mat2str(b)])
				disp(['r^2 = ', num2str(rsq)])
				disp(['p for offset & slope = ', mat2str(stats.p)])
				yfit = glmval(b, [0.4:0.1:1.5], 'identity');

				subplot(3,3,2+3*(ibin-1))
				plot(X_7, y_7, 'o')
				hold on
				plot([0.4:0.1:1.5],yfit)
				xlabel('light-off interval time (s)')
				ylabel('first-lick time wrt cue (s)')
				% 
				% 	Regression of LOI vs flick - no rxn
				% 			
				[b, dev, stats] = glmfit(X_norxn, y_norxn);
				rsq = 1 - sum(stats.resid.^2) / sum((y_norxn-nanmean(y_norxn)).^2);
				disp('Not including rxns (within 0.7s).......')
				disp(['offset & slope = ', mat2str(b)])
				disp(['r^2 = ', num2str(rsq)])
				disp(['p for offset & slope = ', mat2str(stats.p)])
				yfit = glmval(b, [0.4:0.1:1.5], 'identity');

				subplot(3,3,3+3*(ibin-1))
				plot(X_norxn, y_norxn, 'o')
				hold on
				plot([0.4:0.1:1.5],yfit)
				xlabel('light-off interval time (s)')
				ylabel('first-lick time wrt cue (s)')
			end
			% 
			% 	Find the rxn-lick trials
			% 
			rxnTrials = find((obj.GLM.tm_lick_wrtCue_s) < 0.7);
			figure,
			subplot(2,2,1)
			histogram(obj.GLM.LOI_s(rxnTrials),2)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with rxn')
			subplot(2,2,2)
			histogram(obj.GLM.LOI_s(rxnTrials),4)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with rxn')
			subplot(2,2,3)
			histogram(obj.GLM.LOI_s(rxnTrials),8)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with rxn')
			subplot(2,2,4)
			histogram(obj.GLM.LOI_s(rxnTrials), 16)
			xlabel('light-off interval time (s)')
			ylabel('# of trials with rxn')

		end

		function plotLOTA(obj, nbins, threshNplot, smoothing, trialRange)
% 			error('WORKING ON IMPLEMENTING TRIAL RANGE START HERE -- looking to see if the baseline is a bleaching problem 2'' non-stationarity')
			if nargin < 2
				nbins = 1;
			end
			if nargin < 3
				threshNplot = 1;
			end
			if nargin < 4
				smoothing = 0;
			end
			if nargin < 5
				trialRange = 1:numel(obj.GLM.cue_s);
			end
			obj.GLM.flush = {};
			% 
			%	Check the object has the appropriate data-style (needs to contain gfit) 
			% 
			if obj.GLM.Mode ~= true
				error('Need GLM-compatible statsobject from version 2.x and up. (10/11/18)')
			end
			obj.GLM.tm17_lick_wrtCue_s = 17*ones(numel(obj.GLM.cue_s), 1);
			obj.GLM.tm17_lick_wrtCue_s(obj.GLM.fLick_trial_num) =  obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
			% 
			% 	Get lightsOff positions if doesn't exist
			% 
			obj.GLM.pos.lampOff = obj.getXPositionsWRTgfit(obj.GLM.lampOff_s);
			obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);
			% 
			% 	Get LO-interval from LampOff to Cue-On if haven't done yet
			% 
			if ~isfield(obj.GLM, 'LOI_s')
				obj.GLM.LOI_s = obj.GLM.cue_s - obj.GLM.lampOff_s;
			end
			% 
			% 	Now that we have lamp-off positions, let's make a lampOff triggered array
			% 
% 			if ~isfield(obj.GLM, 'LOTA')
				baseline_len = 50000;
				LOTA_len = 1501+baseline_len;
				obj.GLM.LOTA = nan(numel(obj.GLM.pos.lampOff), LOTA_len);
				obj.GLM.LOTA_startpos = baseline_len + 1;
				obj.GLM.LOTA_xticks = [-baseline_len/1000:0.001:1.5];
				for iTrial = 1:numel(obj.GLM.pos.lampOff)
					% 
					% 	For now, don't include the cue!
					% 
					pos1 = obj.GLM.pos.lampOff(iTrial) - baseline_len;
					pos2 = obj.GLM.pos.cue(iTrial)-1;
					LOTA_end = pos2-pos1 + 1;
                    try 
    					obj.GLM.LOTA(iTrial, 1:LOTA_end) = obj.GLM.gfit(pos1:pos2);
                    catch
                        warning(['Cue/LO positions not in gfit! Trial#', num2str(iTrial)])
                    end
				end
% 			end
			% 
			% 	Now bin stuff based on trial length
			% 
			if nbins > 1
				[N,edges,Bin] = histcounts(obj.GLM.tm17_lick_wrtCue_s(trialRange), nbins);
				for ibin = 1:nbins
					binLegend{ibin} = [num2str(round(edges(ibin),1)) 's-' num2str(round(edges(ibin+1),1)) 's, N=' num2str(N(ibin))]; 
				end
			else
				binLegend = {'all trials'};
				N = numel(obj.GLM.tm_lick_wrtCue_s);
				edges = [0,17];
				Bin = ones(1, N);
			end
			% 
			% 	Plot it
			% 
			figure
            C = linspecer(nbins); 
            axes('NextPlot','replacechildren', 'ColorOrder',C);
			hold on
			for ibin = fliplr(1:nbins)
				if N(ibin) >= threshNplot
					trialsInBin = find(Bin == ibin);
					binnedLOTA = nanmean(obj.GLM.LOTA(trialsInBin, :),1);
					if ~smoothing
						plot(obj.GLM.LOTA_xticks,binnedLOTA, 'DisplayName', binLegend{ibin})
					else
						plot(obj.GLM.LOTA_xticks,obj.smooth(binnedLOTA, smoothing), 'DisplayName', binLegend{ibin})
					end
				end
			end
			plot([0,0], [min(binnedLOTA), max(binnedLOTA)],'k-', 'DisplayName', 'Lamp-Off')
			legend('show')
			xlabel('Time relative to Lamp-Off (s)')
			ylabel('dF/F')
		end

		



		function PPencodingGLM(obj)
			% 
			% (DRAFT: 10/10/18) 
			% 
			% An encoding model aims to describe p(r|x), the probability of response 
			% 	r given a set of external variables x on a single trial.
			% 
			% 	r = photometry signal before first lick (or up to some defined point before lick)
			% 	x = {lick time, lights off time (or cue-on time), movement signals}
			% 	th = model parameters (e.g., weights)
			% 
			% -- When dealing with spike trains, they define this response as a time-varying spike rate, where they have binned time over
			% 		a certain range of values. For our purposes, I feel that lam_t is simplified to be just dF/F
			% 
			% -- When deadling with spike trains, we get a Poisson probabolity of a rate. Is poisson the right model for 
			% 		photometry? Could we plug in dF/F as the "rate"?
			% 
			% If so, then:
			% 
			% 	p(r|x,th)= @x xt* for 0:T{ p(r_t|x,th)} = p(r_1|x,th)*p(r_2|x,th)*p(r_3|x,th)...
			% 		r_t = spike count at time = t --> dF/F  measurement for bin
			% 		lam_t = rate at t --> slope of dF/F???
			% 		d = time bin width (so d (s) * lam_t (sp/s) = sp)
			% 						   (so d (s) * rate (dF/F/s = sF/F))
			% 		
			% 	If Poisson:
			% 	p(r|x,th): @x xt* for 0:T{ (d*lam_t)^r_t * e^(-d*lam_t) }
			% 	p(r|x,th): @x xt* for 0:T{ (1 [ms] *ddFF [dF/F/ms])^dFF * e^(-1 [ms] * ddFF [dF/F/ms]) }
			% 					units: dF/F ^ dF/F * [no unit] & -dF/F ---- how does that work out?
			% 
			% 	since th = {{ki}, h}, which are used to define rate, lam_t, I think no parameters to fit.
			% 		seems like all the fitting is in the spike rate...
			% 
			%------------------------------------

		end




		function CTAencodingGLM(obj, Mode, trials)
			% 
			% (DRAFT: 10/10/18) ------- this can't be right -- too many observations for the number of predictors...
			% 		The model we've seen in the paper 
			% 	
			% 
			% 
			% 
			% 	ENCODING MODEL - how are sensory variables +/- movements encoded in the neural timeseries?
			% 
			% 	Mode: 
			% 		'allTS': 	consider all timepoints in the CTA timeseries
			% 
			% 		'2s':		consider only times up to 2s post cue and exclude any trials where the lick happens before this 
			% 					(though can still use history of earlier movement as predictor)
			% 
			% 	bins:
			% 		'all' or [n:m,p,q] 	specify which trials or bins to consider. if is average data, then is bins, otherwise is trials in chronological order
			% 
			%------------------------------------

			disp('-----------------------------')
			disp('Running Encoding GLM for Cue-Aligned Data')
			disp('Y = (trial # x timepoint), X = (trial # x predictor [e.g., lights-off-time])')
			if nargin < 3 || strcmpi(trials, 'all')
				disp('	Using all trials (default)')
				trials = 1:obj.BinParams.nbins_CLTA;
			else
				disp(['	Using a subset of trials: ' mat2str(trials)])
			end
			if nargin < 2
				disp('	Using entire cue-aligned timeseries (1:18501)')
				Mode = 'allTS'
			else
				disp(['	Running with ' Mode, ' Mode'])
			end

			smoothing = obj.Plot.smooth_kernel;

			% -----------------------------------
			% 	X1 = lights off time
			% -----------------------------------
			% X1 = obj.iv.lamp_off_by_trial; %%%%%%%%%%% need to calc this

			% -----------------------------------
			%	X2 = cue on time
			% -----------------------------------
			X2 = (obj.Plot.first_post_cue_position-1) * ones(numel(trials), 1);

			% -----------------------------------
			%	X3 = first lick time
			% -----------------------------------
			X3 = cell2mat({obj.BinParams.s(trials).CLTA_Min})';

			% ------------------------------------
			%	X4 = movement timeseries
			% ------------------------------------


			% -------------------------------------
			% 	Combine X arrays
			% -------------------------------------
			X = horzcat(X2,X3);


			% -------------------------------------
			%	Define the y array
			% -------------------------------------
			smoothedSets = cellfun(@(x) obj.smooth(x, smoothing), obj.BinnedData.CTA, 'UniformOutput', 0);
			y = cell2mat(smoothedSets');

			% -------------------------------------
			% 	Do the regression
			% -------------------------------------
			[b, ~, stats] = glmfit(X,y);
			yfit = glmval(b,X, 'identity');
			[rsq, ~] = obj.rSquared(y, yfit);



		end










		function linfit_LTA_baseline(obj, Mode, UIrange) % Will piecewise fit the dataset (CTA or LTA mode)
			% 
			% 	Modes: 
			% 		window: 	give range of times (in sec) before lick to take average of: 'win', [-6.5, -5]
			% 						* note: max prior time is 6.5sec
			% 		sliding: 	give a window range and this will get slid over the data starting far out and moving in.
			% 						* should only take complete windows						'slide', [500winsize, 0overlap]
			% 
			if nargin < 3 && strcmpi(Mode, 'win')
				UIrange = [-6.5, -5];
				xmin = find(obj.Plot.LTA.xticks.s > -6.5, 1, 'first');
				xmax = find(obj.Plot.LTA.xticks.s > -5, 1, 'first');
			else
				if numel(UIrange) ~= 2, error('UI range should be the times in sec to set the window wrt lick, e.g., [-6.5, -5], when used in window Mode');, end
				xmin = find(obj.Plot.LTA.xticks.s > UIrange(1), 1, 'first');
				xmax = find(obj.Plot.LTA.xticks.s > UIrange(2), 1, 'first');
				windowcenter = xmin + (xmax-xmin)/2;
			end

			if strcmpi(Mode, 'win')
				% 
				% 	Find time centers for the bins and range of bins
				% 	
				binTimeCenters = {obj.BinParams.s.CLTA_Center};
				% 
				% 	Collect the means of the baselines
				% 
				smoothLTA = cellfun(@(x) obj.smooth(x), {obj.BinnedData.LTA.All}, 'UniformOutput', 0);
				windows = cellfun(@(x) nanmean(x(xmin:xmax)), smoothLTA);
				% 
				% 	Plot the baselines vs the lick time (using bin center)
				% 
				f1 = figure, 
	            C = linspecer(numel(windows)); 
            	axes('NextPlot','replacechildren', 'ColorOrder',C);
            	hold on, cellfun(@(x,y) plot(-x,y, '.', 'MarkerSize',30), binTimeCenters, num2cell(windows));
            	legend(obj.BinParams.Legend_s.CLTA)
            	xlabel('LTA Bin Center (s wrt Lick)')
            	ylabel('Mean dF/F in Window')
            	title(['LTA Mean Baseline: Window=[' num2str(UIrange(1)), ', ' num2str(UIrange(2)) '] sec wrt Lick'])
				% 
				% 	Do the linear regression:
				% 
				[b, dev, stats] = glmfit(cell2mat(binTimeCenters),windows);
				yfit = glmval(b,-cell2mat(binTimeCenters), 'identity');
				plot(-cell2mat(binTimeCenters),yfit,'-','LineWidth',2)
                obj.Stat.linfit_LTA_baseline.b = [];
                obj.Stat.linfit_LTA_baseline.dev = [];
                obj.Stat.linfit_LTA_baseline.stats = {};
				obj.Stat.linfit_LTA_baseline(1).b = b;
				obj.Stat.linfit_LTA_baseline(1).dev = dev;
				obj.Stat.linfit_LTA_baseline(1).stats = stats;
				% 
				% 
				% 
			end

			if strcmpi(Mode, 'slide')
				% 
				% 	We will do this procedure for all possible sliding windows out to 7 sec before the lick (that's the earliest we can go...)
				% 

			end

		end


		function binnedFits = LTA_slope(obj, Mode, binrange) % Will calculate a linear fit to the slope to measure the slope
			% 
			% 	In general:	
			% 		For each bin, calculate the best linear fit by excluding timepoints
			% 		Start by going from max distance to cue up to the inflection point and start trimming
			% 		Smooth the data first. Use the BINNED AVERAGE
			% 		So for bin 2.5-3.5 sec...
			% 			Calc linear fit of the data between -3.5 to 0 (lick time) -- calc p value of the slope
			% 			Now iterate: While the fit is improving, chop points off the right side (we know some of these should be excluded)
			% 				Once p value stops changing significantly, stop. Report the time before lick we went to
			% 			Now iterate again: While fit improving, chop points off the left side. Report where we land
			% 		Then for ALL the trials, fit a slope in that window
			% 		Then compare the variance in slope within a bin to the variance in slope between bins
			% 
			% 		NOTE: best if the same number of trials in each bin, so we might want to consider that in the original binning
			if nargin < 2
				Mode = 'alt';
				binrange = 1:obj.BinParams.nbins_CLTA;
			end
			% 
			% 	1. Smooth the binned data
			% 
			smoothLTA = cellfun(@(x) obj.smooth(x), {obj.BinnedData.LTA.All}, 'UniformOutput', 0);
			% 
			% 	2. Get max bin time from the lick (and positions)
			% 
			leftBinEdge_s = {obj.BinParams.s.CLTA_Max};
            leftBinEdge_s = cellfun(@(x) {-x}, leftBinEdge_s);
			leftBinEdge_pos = cellfun(@(x) find(obj.Plot.LTA.xticks.s > x, 1, 'first'), leftBinEdge_s, 'UniformOutput', 0);
            leftBinEdge_s = cell2mat(leftBinEdge_s);
            leftBinEdge_pos = cell2mat(leftBinEdge_pos);
			% 
			% 	3. Iterate across bins, with linear fit 
			% 
			stepSize_ms_RHS = 5;
			stepSize_ms_LHS = 20;
			% 
			% 		We would like a decent linear fit, so we will keep going until our p-value gets below this level OR stops changing by less than some step
			% 			We could also do ADAGRAD or something in the future to change our step size depening on the p-value change (if not changing much, step bigger in ms)
			% 
			% 
			% *********** add feature to keep the best fit and be able to return to it later on - like if we reach the end and it's not as good as an intermediate fit, can keep that
			% 
            BinWidth_ms = 1000*([obj.BinParams.s.CLTA_Max]);
            % minBinWidth_ms = min(BinWidth_ms(binrange));
			stopThreshMax = 0.99; 
			stopThreshDelta = 0.00001; % if we change by less than this number our p-value, we will stop looking.
			backtrackDelta = -0.005; % if we are making things MUCH worse...
			maxIterRHS = round((2*BinWidth_ms/10)/stepSize_ms_RHS); % only go 20% into the bin
			maxIterLHS = round((5*BinWidth_ms/10)/stepSize_ms_LHS); % only go 50% into the bin
			% 
			binnedFits = {};
			bestfit = {};
			% 
			f1 = figure;
			C = linspecer(2*numel(binrange)); 
        	axes('NextPlot','replacechildren', 'ColorOrder',C);
			yMin = nanmin(cellfun(@(x) nanmin(x), smoothLTA));
			yMax = nanmax(cellfun(@(x) nanmax(x), smoothLTA));
            plot([0,0],[yMin, yMax], 'k-', 'DisplayName', 'Lick')
			hold on
			leg = {'Lick'};
			% 
			for ibin = binrange
				disp(['------------------- \n BIN #' num2str(ibin)])
				startLeft = leftBinEdge_pos(ibin);
				startRight = find(obj.Plot.LTA.xticks.s > -0, 1, 'first'); 
				left = startLeft;
				right = startRight;
				rsq = 0;
				delta = 1;
				iter = 1;
				bestfit(ibin).b = [];
				bestfit(ibin).dev = [];
				bestfit(ibin).stats = {};
				bestfit(ibin).rsq = 0;
				bestfit(ibin).left = 0;
				bestfit(ibin).right = 0;
				% 
				% 	Sequential L/R SGD-oid
				% 
				if strcmpi(Mode, 'seq')
					% 
					%  Conduct the RHS
					% 
					while true
						% 
						% 	Fit the points between startLeft and startRight in this bin
						% 
						[b, ~, stats] = glmfit(obj.Plot.LTA.xticks.s(left:right), smoothLTA{ibin}(left:right));
						rsqNew = 1 - sum(stats.resid.^2) / sum((smoothLTA{ibin}(left:right)-nanmean(smoothLTA{ibin}(left:right))).^2);
						delta = rsqNew - rsq;
						disp(['r^2 = ' num2str(rsqNew)])
						if delta < backtrackDelta
							right = right + stepSize_ms;
							disp(['r^2 was better before. Keeping old rsq = ', num2str(rsq)])
							break
						end
						rsq = rsqNew;
						iter = iter + 1;
						if abs(delta) < stopThreshDelta || rsq > stopThreshMax || iter > maxIterRHS(ibin)
	                        break
						else
							right = right - stepSize_ms;
						end
					end
					% 
					%  Conduct the LHS
					% 
	                left = left + stepSize_ms;
	                iter = 1;
					while true
						% 
						% 	Fit the points between startLeft and startRight in this bin
						% 
						[b, dev, stats] = glmfit(obj.Plot.LTA.xticks.s(left:right), smoothLTA{ibin}(left:right));
						rsqNew = 1 - sum(stats.resid.^2) / sum((smoothLTA{ibin}(left:right)-nanmean(smoothLTA{ibin}(left:right))).^2);
						delta = rsqNew - rsq;
						disp(['r^2 = ' num2str(rsqNew)])
						if delta < backtrackDelta
							left = left - stepSize_ms;
							disp(['r^2 was better before. Keeping old rsq = ', num2str(rsq)])
							break
						end
						rsq = rsqNew;
						iter = iter + 1;
						if abs(delta) < stopThreshDelta || rsq > stopThreshMax || iter > maxIterLHS(ibin)
							break
						else
							left = left + stepSize_ms;
						end
					end
				% 	
				% Alternating SGD-oid
				% 
				else 
					while true
						% 
						%  Conduct the RHS alternating with the LFS
						% 
						if iter < maxIterRHS(ibin)
							% 
							% 	Fit the points between startLeft and startRight in this bin
							% 
							[b, dev, stats] = glmfit(obj.Plot.LTA.xticks.s(left:right), smoothLTA{ibin}(left:right));
							rsqNew = 1 - sum(stats.resid.^2) / sum((smoothLTA{ibin}(left:right)-nanmean(smoothLTA{ibin}(left:right))).^2);
							delta = rsqNew - rsq;
							disp(['r^2 = ' num2str(rsqNew)])
							rsq = rsqNew;
							% 
							% 	Check if this is the best fit so far...
							% 
							if rsq > bestfit(ibin).rsq
								bestfit(ibin).rsq = rsq;
								bestfit(ibin).b = b;
								bestfit(ibin).dev = dev;
								bestfit(ibin).stats = stats;
								bestfit(ibin).left = left;
								bestfit(ibin).right = right;
							end
							% 
							if abs(delta) < stopThreshDelta 
								disp('abs(RHS delta) < stopThreshDelta')
								break
							elseif rsq > stopThreshMax
								disp('RHS r^2 > stopThreshMax')
		                        break
	                       	elseif delta < backtrackDelta
								right = right + stepSize_ms_RHS;
								disp(['r^2 was better before. Keeping old rsq = ', num2str(rsq)])
							else
								right = right - stepSize_ms_RHS;
							end
						else
							disp('Reached Max Iter RHS')
						end
						% 
						if iter < maxIterLHS(ibin)
							% 
							%  Conduct the LHS
							% 
			                left = left + stepSize_ms_LHS;
							% 
							% 	Fit the points between startLeft and startRight in this bin
							% 
							[b, dev, stats] = glmfit(obj.Plot.LTA.xticks.s(left:right), smoothLTA{ibin}(left:right));
							rsqNew = 1 - sum(stats.resid.^2) / sum((smoothLTA{ibin}(left:right)-nanmean(smoothLTA{ibin}(left:right))).^2);
							delta = rsqNew - rsq;
							disp(['r^2 = ' num2str(rsqNew)])
							rsq = rsqNew;
							iter = iter + 1;
							% 
							% 	Check if this is the best fit so far...
							% 
							if rsq > bestfit(ibin).rsq
								bestfit(ibin).rsq = rsq;
								bestfit(ibin).b = b;
								bestfit(ibin).dev = dev;
								bestfit(ibin).stats = stats;
								bestfit(ibin).left = left;
								bestfit(ibin).right = right;
							end
							% 
							if abs(delta) < stopThreshDelta
								disp('abs(LHS delta) < stopThreshDelta')
								break
							elseif rsq > stopThreshMax
								disp('LHS r^2 > stopThreshMax')
								break
							elseif delta < backtrackDelta
								left = left - stepSize_ms_LHS;
								disp(['r^2 was better before. Keeping old rsq = ', num2str(rsq)])
							else
								left = left + stepSize_ms_LHS;
							end
						else
							disp('Reached Max Iter LHS')
						end
						% 
						% 	Update iter and decide if time to stop
						% 
						iter = iter + 1;
						% 
						if iter > maxIterLHS(ibin) && iter > maxIterRHS(ibin)
							disp('Reached Max Iter RHS & LHS. Breaking.')
							break;
						end
					end
					%
					%  Update the legend
					% 
					leg{end+1} = obj.BinParams.Legend_s.CLTA{ibin};
					leg{end+1} = [obj.BinParams.Legend_s.CLTA{ibin}, ' Fit']; 
				end
				% 
				% 	Update the file:
				% 
				binnedFits(ibin).b = bestfit(ibin).b;
				binnedFits(ibin).dev = bestfit(ibin).dev;
				binnedFits(ibin).stats = bestfit(ibin).stats;
				binnedFits(ibin).rsq = bestfit(ibin).rsq;
				binnedFits(ibin).left = bestfit(ibin).left;
				binnedFits(ibin).right = bestfit(ibin).right;
				binnedFits(ibin).bin_num = ibin;
				%  
				% 	Display the final r^2:
				% 
				disp(['Final r^2: ', num2str(binnedFits(ibin).rsq)])
	            % 
				% 	Update the plot:
				% 
				if binnedFits(ibin).rsq > 0.8
					plot(obj.Plot.LTA.xticks.s,smoothLTA{ibin})
					yfit = glmval(binnedFits(ibin).b, obj.Plot.LTA.xticks.s(binnedFits(ibin).left:binnedFits(ibin).right), 'identity');
					plot(obj.Plot.LTA.xticks.s(binnedFits(ibin).left:binnedFits(ibin).right),yfit,'-','LineWidth',2)
				else
					plot([0],[0])
					plot([0],[0])
				end
				%
			end
			% 
			% Add legened, etc:
			% 
			legend(leg)
			xlim([-obj.Plot.wrtCue.Events.s.total_time_ms, 10])
			title(['LTA with slope fits: Bins ', num2str(1), '-', num2str(obj.BinParams.nbins_CLTA)])
			xlabel('Time wrt First Lick (s)')
			ylabel('dF/F')
			% 
			% 	*** WE CAN USE THE LEFT POINT OF THE FIT AS THE LOW POINT OF THE BIN!!!!!!!!
			% 
			% 
			% 	Store the binnedFits in the obj
			% 
			obj.Stat.binnedLTASlopeFits = binnedFits;
		end


		function binnedFits = linreg_slope(obj, binnedFits)
			% 
			% 	Find all the bins with a reasonable fit (r^2 > 80%)
			% 
			allBinNums = [binnedFits(:).bin_num];
			allBinCenters = [obj.BinParams.s(allBinNums).CLTA_Center];
			validFitBins = find([binnedFits.rsq] > 0.9);
			validBinCenters = [obj.BinParams.s(validFitBins).CLTA_Center];
			% 
			% 	Plot the slope
			% 
			allSlopes = [binnedFits.b];
            allSlopes = allSlopes(2,:);
			validSlopes = [binnedFits(validFitBins).b];
            validSlopes = validSlopes(2,:);
			% 
			% 	Regress the slopes against the bin-center
			% 
			[b, dev, stats] = glmfit(validBinCenters, validSlopes);
			rsq = 1 - sum(stats.resid.^2) / sum((validSlopes-nanmean(validSlopes)).^2);
			disp(['r^2 = ', num2str(rsq)])
            figure
			plot(allBinCenters, allSlopes, 'o')
            hold on
			yfit = glmval(b, validBinCenters, 'identity');
			plot(validBinCenters,yfit,'-','LineWidth',2)
			
		end

		function pwfit(obj, Mode) % Will piecewise fit the dataset (CTA or LTA mode)
			warning('Not Implemented');
		end

%-----------------------------------------------------------------------
% 
% 	METHODS: Lag Regression GLM
% 
% ----------------------------------------------------------------------


	function Z = zScoreVector(obj, v);
		% 
		% 	Applies Z score to a vector...
		% 
		d_STD = nanstd(v);
		d_mean = nanmean(v);
		% 
		Z = (v - d_mean)./d_STD;
	end

	function trialRange = getTrialRangeSansNoLicks(obj, maxConsecNoLickTrials)
		% 
		% 	Returns trialRange = [minTrial, maxTrial] = [1, maxTrial], where maxTrial is the
		% 	last lick+ trial before string of >maxConsecNoLickTrials
		%
	 	%	Used with obj.baselineGLM() 
	 	%
	 	trialRange = [1,numel(obj.GLM.cue_s)];
	 	noLickTrials = setdiff(1:numel(obj.GLM.cue_s),obj.GLM.fLick_trial_num); 
	 	consecIdxs = find(noLickTrials(maxConsecNoLickTrials:end)-maxConsecNoLickTrials+1==noLickTrials(1:end-maxConsecNoLickTrials+1));
	 	if ~isempty(consecIdxs)
	 		trialRange(2) = noLickTrials(consecIdxs(1))-1;
 		end
	end

	function [Xn, Xtest, an, atest] = leaveOneOut(obj, X, a, nTrialsTest, idx, dataType)
		% 
		%	idx = [indicies of items to leave out] range (1:numItems) 
		% 
		if nargin < 6
			dataType = 'lagRegression';
		end
		if strcmpi(dataType,'lagRegression') || strcmpi(dataType,'baselineGLM')
			% 
			% 	Each point in 'a' is a trial, so just cut out trials from a
			%
			if nargin < 5
				for iTestTrial = 1:nTrialsTest
					idx(iTestTrial) = randi(numel(a));
				end
			end
			if nargin < 4
				nTrialsTest = 1;
			end
			% 
			% 
			an = a;
			an(idx) = [];
			atest = a(idx);
			% 
			%
			Xn = X;
			Xn(:, idx) = [];
			Xtest = X(:, idx);
		else
			error('Not Implemented');
		end
	end

	function [th, X] = leaveOneOutXValidation(obj, X, a, d, lam, dataType, nHx, aplot, aidxs, plot_on, distrib)
		if nargin < 10
			plot_on = true;
		end
		if nargin < 11
			distrib = 'normal';
		end
		if strcmpi(dataType, 'lagRegression')
			for iTest = 1:numel(a)
				% 
				% 	Generate sets
				% 
				[Xni, Xtesti, ani, atesti] = obj.leaveOneOut(X, a, 1, iTest, dataType);
				% 
				% 	Calculate fit
				% 
				thi = (Xni*Xni.'+lam.*eye(d))\Xni*ani.';
				% 
				yFiti = obj.calcYfit(thi, Xni);
				% 
				%	Calculate the test prediction 
				% 
				yPredictedi = thi'*Xtesti;
				% 
				% 	Calculate the Loss
				% 
				obj.Stat.lrGLM.MSE_meanSn(iTest) = 1/numel(ani)*sum((ani - mean(ani)).^2);
				obj.Stat.lrGLM.MSE_Sn(iTest) = 1/numel(ani)*sum((ani - yFiti).^2);
				obj.Stat.lrGLM.MSE_meanSnOnStest(iTest) = 1/numel(atesti)*sum((atesti - mean(ani)).^2);
				obj.Stat.lrGLM.MSE_Stest(iTest) = 1/numel(atesti)*sum((atesti - yPredictedi).^2);
				% 
				% 
				obj.Stat.lrGLM.Xn(1:d, 1:numel(a)-1, iTest) = Xni;
				obj.Stat.lrGLM.Xtest(1:d, 1, iTest) = Xtesti;
				obj.Stat.lrGLM.an(iTest, 1:numel(a)-1) = ani; 
				obj.Stat.lrGLM.atest(iTest, 1) = atesti;
				obj.Stat.lrGLM.th(1:d, iTest) = thi;
				obj.Stat.lrGLM.yFit(iTest, 1:numel(a)-1) = yFiti;
				obj.Stat.lrGLM.yPredicted(iTest, 1) = yPredictedi; 
			end
			% 
			%	Calculate the Xvalidation stats 
			% 		** NOT YET modified based on Chicha feedback on 12/18/18
			% 
			error('Need to fix based on Chicha feedback!')
			obj.Stat.lrGLM.XV.aveMSE_Snmean = mean(obj.Stat.lrGLM.MSE_meanSn);
			obj.Stat.lrGLM.XV.aveMSE_Sn = mean(obj.Stat.lrGLM.MSE_Sn);
			obj.Stat.lrGLM.XV.aveMSE_SnmeanOnStest = mean(obj.Stat.lrGLM.MSE_meanSnOnStest);
			obj.Stat.lrGLM.XV.aveMSE_Stest = mean(obj.Stat.lrGLM.MSE_Stest);
			obj.Stat.lrGLM.XV.CI_Snmean = obj.CI95(obj.Stat.lrGLM.MSE_meanSn); 
			obj.Stat.lrGLM.XV.CI_Sn = obj.CI95(obj.Stat.lrGLM.MSE_Sn);
			obj.Stat.lrGLM.XV.CI_SnmeanOnStest = obj.CI95(obj.Stat.lrGLM.MSE_meanSnOnStest);
			obj.Stat.lrGLM.XV.CI_Stest = obj.CI95(obj.Stat.lrGLM.MSE_Stest);
			disp('*************** STATS ****************')
	        disp(['**   Mean Average Sn Loss (null case) = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_Snmean,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_Snmean,2)) '   **'])
	        disp(['**   Mean Training Loss = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_Sn,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_Sn,2)) '    **'])
	        disp(['**   Mean Average Sn Loss on Stest = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_SnmeanOnStest,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_SnmeanOnStest,2)) '    **'])
	        disp(['**   Mean Test Loss = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_Stest,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_Stest,2)) '    **'])
	        disp(['**   Model Improvement (delta MSE test) = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_SnmeanOnStest-obj.Stat.lrGLM.XV.aveMSE_Stest,2)), '    **'])
	        % 
	        % 	Calculate the average model and CI of coefficients
	        % 
	        obj.Stat.lrGLM.XV.ave_th = mean(obj.Stat.lrGLM.th, 2);
	        obj.Stat.lrGLM.XV.CI_th = obj.CI95(obj.Stat.lrGLM.th);
	        if plot_on
		        figure,
		        subplot(2,3,4)
		        hold on
	            h1 = plot(flipud(-(1:numel(obj.Stat.lrGLM.XV.ave_th(1:nHx)))'.*ones(size(obj.Stat.lrGLM.th(1:nHx, :)))), flipud(obj.Stat.lrGLM.th(1:nHx, :)), 'co');
		        h2 = plot(fliplr(-(1:numel(obj.Stat.lrGLM.XV.ave_th(1:nHx)))), flipud(obj.Stat.lrGLM.XV.CI_th(1:nHx, 2)), 'ro-', 'DisplayName', 'Upper CI');
		        h3 = plot(fliplr(-(1:numel(obj.Stat.lrGLM.XV.ave_th(1:nHx)))), flipud(obj.Stat.lrGLM.XV.CI_th(1:nHx, 1)), 'ro-', 'DisplayName', 'Lower CI');
		        h4 = plot(fliplr(-(1:numel(obj.Stat.lrGLM.XV.ave_th(1:nHx)))), flipud(obj.Stat.lrGLM.XV.ave_th(1:nHx)), 'ko-', 'DisplayName', 'Ave th');
		        legend([h2, h3, h4])
		        title('Looking back: theta for influence of n-trials back')
		        
		        subplot(2,3,5)
		        hold on
		        h1 = plot(0, flipud(obj.Stat.lrGLM.th(end, :)), 'co');
		        h2 = plot(0, flipud(obj.Stat.lrGLM.XV.CI_th(end, 2)), 'ro', 'DisplayName', 'Upper CI');
		        h3 = plot(0, flipud(obj.Stat.lrGLM.XV.CI_th(end, 1)), 'ro', 'DisplayName', 'Lower CI');
		        h4 = plot(0, flipud(obj.Stat.lrGLM.XV.ave_th(end)), 'ko', 'DisplayName', 'Ave th');
		        legend([h2,h3,h4])
		        title('Baseline offset')

		        subplot(2,3,6)
		        hold on
		        if size(obj.Stat.lrGLM.th, 1) - nHx > 1
		        	idx = nHx+1 : size(obj.Stat.lrGLM.th,1)-1;
			        h1 = plot(idx, flipud(obj.Stat.lrGLM.th(idx, :)), 'co');
			        h2 = plot(idx, flipud(obj.Stat.lrGLM.XV.CI_th(idx, 2)), 'ro', 'DisplayName', 'Upper CI');
			        h3 = plot(idx, flipud(obj.Stat.lrGLM.XV.CI_th(idx, 1)), 'ro', 'DisplayName', 'Lower CI');
			        h4 = plot(idx, flipud(obj.Stat.lrGLM.XV.ave_th(idx)), 'ko', 'DisplayName', 'Ave th');
		        	legend([h2,h3,h4])
	        	end
		        title('Other fit parameters...')
		        % 
		        % 	Plot the fit
		        % 
		        obj.Stat.lrGLM.XV.AveYFit = obj.Stat.lrGLM.XV.ave_th'*X;
		        subplot(2,1,1)
		        hold on, 
				plot(a, '-o', 'DisplayName', 'Lick Times'), 
				plot(obj.Stat.lrGLM.XV.AveYFit, '-o', 'DisplayName', 'Prediction (yFit)')
		        legend('show')
		        xlabel('Trial #')
		        ylabel('lick time (s)')
	        end

	        ave_th = obj.Stat.lrGLM.XV.ave_th;
        elseif strcmpi(dataType, 'baselineGLM')
        	if nHx > 0
	        	nHxIdx = numel(obj.Stat.baselineGLM.FeatureMap) - nHx;
        	end
			for iTest = 1:numel(a)
				% 
				% 	Generate sets
				% 
				[Xni, Xtesti, ani, atesti] = obj.leaveOneOut(X, a, 1, iTest, dataType);
				% 
				% 	Calculate fit
				% 
				if strcmp(distrib, 'normal')
					thi = (Xni*Xni.'+lam.*eye(d))\Xni*ani.';
					% 
					yFiti = obj.calcYfit(thi, Xni);
					% 
					%	Calculate the test prediction 
					% 
					yPredictedi = thi'*Xtesti;
				elseif strcmp(distrib, 'inv-gauss')
    				warning('untested')
	        		[thi,~,~] = glmfit(Xni',ani,'inverse gaussian', 'constant', 'off');
	        		yFiti = glmval(thi,Xni',-2, 'constant', 'off')';
	        		yPredictedi = glmval(thi,Xtesti',-2, 'constant', 'off')';
	        	elseif strcmp(distrib, 'gamma')
    				warning('untested')
	        		[thi,~,~] = glmfit(Xni',ani,'gamma', 'constant', 'off');
	        		yFiti = glmval(thi,Xni','reciprocal', 'constant', 'off')';
	        		yPredictedi = glmval(thi,Xtesti','reciprocal', 'constant', 'off')';
				else
					error('not implemented');
				end
				% 
				% 	Calculate the Loss
				% 
				obj.Stat.lrGLM.MSE_meanSn(iTest) = 1/numel(ani)*sum((ani - mean(ani)).^2);
				obj.Stat.lrGLM.MSE_Sn(iTest) = 1/numel(ani)*sum((ani - yFiti).^2);
				obj.Stat.lrGLM.MSE_meanSnOnStest(iTest) = 1/numel(atesti)*sum((atesti - mean(ani)).^2);
				obj.Stat.lrGLM.MSE_Stest(iTest) = 1/numel(atesti)*sum((atesti - yPredictedi).^2);
				% 
				% 
				obj.Stat.lrGLM.Xn(1:d, 1:numel(a)-1, iTest) = Xni;
				obj.Stat.lrGLM.Xtest(1:d, 1, iTest) = Xtesti;
				obj.Stat.lrGLM.an(iTest, 1:numel(a)-1) = ani; 
				obj.Stat.lrGLM.atest(iTest, 1) = atesti;
				obj.Stat.lrGLM.th(1:d, iTest) = thi;
				obj.Stat.lrGLM.yFit(iTest, 1:numel(a)-1) = yFiti;
				obj.Stat.lrGLM.yPredicted(iTest, 1) = yPredictedi; 
			end
			%
			% 	Finally, fit the entire dataset to return the thetaBest on Sn...
			% 
			% 
			% 	Calculate fit
			% 
			if strcmp(distrib, 'normal')
				th = (X*X.'+lam.*eye(d))\X*a.';
				% 
				yFit = obj.calcYfit(th, X);
			elseif strcmp(distrib, 'inv-gauss')
				warning('untested')
        		[th,~,stats] = glmfit(X',a,'inverse gaussian', 'constant', 'off');
        		yFit = glmval(th,X',-2, 'constant', 'off')';
        		obj.Stat.lrGLM.stats = stats;
        	elseif strcmp(distrib, 'gamma')
				warning('untested')
        		[th,~,stats] = glmfit(X',a,'gamma', 'constant', 'off');
        		yFit = glmval(th,X','reciprocal', 'constant', 'off')';
        		obj.Stat.lrGLM.stats = stats;
			else
				error('not implemented');
			end
			% 
			% 	Save the fit
			%  
			obj.Stat.lrGLM.Xall = X;
			obj.Stat.lrGLM.aAll = a;
			obj.Stat.lrGLM.thAll = th;
			obj.Stat.lrGLM.yFitAll = yFit;
			% 
	        % 	Calculate the total model and CI of coefficients
	        % 
	        obj.Stat.lrGLM.XV.CI_th = obj.CI95(obj.Stat.lrGLM.th);
			% 
			%	Calculate the Xvalidation stats 
			% 		** updated based on Chicha feedback 12/18/18
			% 
			obj.Stat.lrGLM.XV.aveMSE_Snmean = mean(obj.Stat.lrGLM.MSE_meanSn);
			obj.Stat.lrGLM.XV.aveMSE_Sn = mean(obj.Stat.lrGLM.MSE_Sn);
			obj.Stat.lrGLM.XV.aveMSE_SnmeanOnStest = mean(obj.Stat.lrGLM.MSE_meanSnOnStest);
			obj.Stat.lrGLM.XV.aveMSE_Stest = mean(obj.Stat.lrGLM.MSE_Stest);
			obj.Stat.lrGLM.XV.CI_Snmean = obj.CI95(obj.Stat.lrGLM.MSE_meanSn); 
			obj.Stat.lrGLM.XV.CI_Sn = obj.CI95(obj.Stat.lrGLM.MSE_Sn);
			obj.Stat.lrGLM.XV.CI_SnmeanOnStest = obj.CI95(obj.Stat.lrGLM.MSE_meanSnOnStest);
			obj.Stat.lrGLM.XV.CI_Stest = obj.CI95(obj.Stat.lrGLM.MSE_Stest);
			
			
			[rsq, ~] = obj.rSquared(a, obj.Stat.lrGLM.yFitAll);
			obj.Stat.lrGLM.rsq = rsq;
			if plot_on
				disp('*************** STATS ****************')
		        disp(['**   Mean Average Sn Loss (null case) = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_Snmean,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_Snmean,2)) '   **'])
		        disp(['**   Mean Training Loss = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_Sn,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_Sn,2)) '    **'])
		        disp(['**   Mean Average Sn Loss on Stest = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_SnmeanOnStest,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_SnmeanOnStest,2)) '    **'])
		        disp(['**   Mean Test Loss = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_Stest,2)), ' +/- ' mat2str(round(obj.Stat.lrGLM.XV.CI_Stest,2)) '    **'])
		        disp(['**   Model Improvement (delta MSE test) = ' num2str(round(obj.Stat.lrGLM.XV.aveMSE_SnmeanOnStest-obj.Stat.lrGLM.XV.aveMSE_Stest,2)), '    **'])
		        disp(['**   Rsq average model on all data = ', num2str(rsq) ' ***'])
	        end
	        
	        if plot_on
		        figure,
		        ax1 = subplot(2,2,3);
		        hold on
		        if nHx > 0
		            h1 = plot(flipud(-(1:numel(obj.Stat.lrGLM.thAll(nHxIdx+1:nHxIdx+nHx)))'.*ones(size(obj.Stat.lrGLM.th(nHxIdx+1:nHxIdx+nHx, :)))), flipud(obj.Stat.lrGLM.th(nHxIdx+1:nHxIdx+nHx, :)), 'co');
			        h2 = plot(fliplr(-(1:numel(obj.Stat.lrGLM.thAll(nHxIdx+1:nHxIdx+nHx)))), flipud(obj.Stat.lrGLM.XV.CI_th(nHxIdx+1:nHxIdx+nHx, 2)), 'ro-', 'DisplayName', 'Upper CI');
			        h3 = plot(fliplr(-(1:numel(obj.Stat.lrGLM.thAll(nHxIdx+1:nHxIdx+nHx)))), flipud(obj.Stat.lrGLM.XV.CI_th(nHxIdx+1:nHxIdx+nHx, 1)), 'ro-', 'DisplayName', 'Lower CI');
			        h4 = plot(fliplr(-(1:numel(obj.Stat.lrGLM.thAll(nHxIdx+1:nHxIdx+nHx)))), flipud(obj.Stat.lrGLM.thAll(nHxIdx+1:nHxIdx+nHx)), 'ko-', 'DisplayName', 'Ave th');
			        legend([h2, h3, h4])
			        set(ax1,'XTick',fliplr(-(1:numel(obj.Stat.lrGLM.thAll(nHxIdx+1:nHxIdx+nHx)))));
			        title('Looking back: theta for influence of n-trials back')
		        end

		        ax = subplot(2,2,4);
		        hold on
		        if size(obj.Stat.lrGLM.th, 1) - nHx > 0
		        	idx = 1 : numel(obj.Stat.baselineGLM.FeatureMap)-nHx;
			        h1 = plot(idx, (obj.Stat.lrGLM.th(idx, :)), 'co'); %flipud
			        h2 = plot(idx, (obj.Stat.lrGLM.XV.CI_th(idx, 2)), 'ro', 'DisplayName', 'Upper CI'); %flipud
			        h3 = plot(idx, (obj.Stat.lrGLM.XV.CI_th(idx, 1)), 'ro', 'DisplayName', 'Lower CI'); %flipud
			        h4 = plot(idx, (obj.Stat.lrGLM.thAll(idx)), 'ko', 'DisplayName', 'th - all data'); %flipud
		        	legend([h2,h3,h4])
	                set(ax,'XTick',idx);
		        	for ilabel = 1:numel(obj.Stat.baselineGLM.FeatureMap)-nHx
				        ax.XAxis.TickLabels{ilabel} = char(obj.Stat.baselineGLM.FeatureMap{ilabel});
			        end
					ax.XAxis.TickLabelRotation = 45;
	        	end
		        title('Other fit parameters...')
		        % 
		        % 	Plot the fit
		        % 
		        subplot(2,1,1)
		        hold on, 
				plot(a, '-o', 'DisplayName', 'Lick Times'), 
				plot(obj.Stat.lrGLM.yFitAll, '-o', 'DisplayName', 'All Data yFit')
		        legend('show')
		        xlabel('Trial #')
		        ylabel('signal (units vary)')
	        end
	        % if nargin > 7
		        % % 
		        % % 	Plot the fit against the real data...
		        % % 
		        % for iTrial = 1:numel(a)
		        % 	modelcat(aidxs == iTrial) =  ave_th.'*X(:, iTrial);
	        	% end

		        % figure
		        % hold on
		        % plot(100.*aplot, 'DisplayName', 'Actual Data in Window', 'linewidth', 3)
          %       plot(100.*obj.smooth(aplot, 100, 'gausssmooth'), 'DisplayName', 'Actual Data in Window', 'linewidth', 3)
		        % plot(modelcat, 'DisplayName', 'Ave Model', 'linewidth', 2)
	        % end

        else
			error('Not implemented')
		end
	end

	function CI = CI95(obj, x)
		if size(x,1) > 1 && size(x,2) > 1
            %
            %   d rows of features, x columns of xvalidations
            %
            for iX = 1:size(x, 1)
                SEM(iX) = std(x(iX, :))/sqrt(length(x(iX, :)));          % Standard Error
                ts(iX, 1:2) = tinv([0.025  0.975],length(x(iX, :))-1);      % T-Score
                CI(iX, 1:2) = mean(x(iX, :)) + ts(iX, :)*SEM(iX);                    % Confidence Intervals
            end
		else
			SEM = std(x)/sqrt(length(x));               % Standard Error
			ts = tinv([0.025  0.975],length(x)-1);      % T-Score
			CI = mean(x) + ts*SEM;                      % Confidence Intervals
		end
	end


	function [th, X, a, yFit] = lagRegressionGLM(obj, nHx, categories, xVstyle, lam, Mode)
		% 
		% 	Lag regression will calculate the time from cue-to-lick for all trials
		% 
		% 	nHx = number of trials of history to consider
		% 
		% 	categories = {'rxn', 'early', 'rew', 'ITI', 'noLick'} (default)
		canned_categories = {'default', 'e/l', 'all-linear', 'lin-cat'};
		xVstyles = {'false', 'leave1out'};
		% 
		% 	Mode = 	'linear' --> predict the time of the current trial's lick based on Hx
		% 			'NLL' --> We will have a feature for each trial-outcome pair, then represent as multiple sigmoids to get a probability
		% 				Not Implemented yet because I'm not sure how to
		% 
		% 	RESET---------------------------------------------
		% 
		obj.Stat.lrGLM = {};
		obj.GLM.flush = {};
		% obj.GLM.flush.idxcat = true; % for trimTimestamps to work correctly
		% ----------------------------------------------------
		% 
		if nargin < 6
			Mode = 'linear';
		end
		if nargin < 5
			lam = 0;
			warning('lam = 0, Model will overfit')
		end
		if nargin < 4
			xVstyle = 'false';
		end
		if nargin < 3 || strcmpi(categories, 'default')
			nCat = 5; % including noLick
			catBounds = [0,0.5, 3.333,7,17];
		elseif strcmpi(categories, 'all-linear')
			nCat = 1; % including noLick
			catBounds = [0,0.5, 3.333,7,17];
		elseif strcmpi(categories, 'lin-cat')
			nCat = 5; % including noLick
			nTimeFeats = 1;
			catBounds = [0,0.5, 3.333,7,17];
		elseif strcmpi(categories, 'e/l')
			nCat = 3; % including noLick
			catBounds = [0,3.333,17];
		else
			error('Not implemented');			
		end
		if nargin < 2
			nHx = 1;
		end
		% 
		% 	Stamp it!
		% 
		obj.GLM.flush.Mode = {'lagRegression', nHx, categories, lam, Mode, datestr(now), '17s represents noLick'};
		% 
		% 	Get trial to start on (can't use any for which we don't have enough Hx)
		% 
		tStart = nHx+1;
		tTotal = numel(obj.GLM.cue_s) - nHx;
		% 
		% 	Get nFeatures
		% 
		if strcmpi(categories, 'lin-cat')
			d = nHx * nCat + nHx;
		else
			d = nHx * nCat;
		end
		% 
		% 	Get timestamps
		% 
		lTBT = 17*ones(1, numel(obj.GLM.cue_s)); 
		lTBT(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
		obj.Stat.lrGLM.lTBT = lTBT;
		% 
		% 	Create the design Matrix
		% 
		X = zeros(d, tTotal);
		% 
		% 	Define outcomeBT reference
		% 
		if strcmp(categories, 'default')
			outcomeBT = nan(1, tTotal);
			obj.Stat.lrGLM.outcomes.Map = {'1 = rxn', '2 = early', '3 = rew', '4 = ITI', '5 = noLick'};
			obj.Stat.lrGLM.outcomes.rxn = intersect(find(lTBT > catBounds(1)), find(lTBT <= catBounds(2)));
			outcomeBT(obj.Stat.lrGLM.outcomes.rxn) = 1;
			obj.Stat.lrGLM.outcomes.early = intersect(find(lTBT > catBounds(2)), find(lTBT <= catBounds(3)));
			outcomeBT(obj.Stat.lrGLM.outcomes.early) = 2;
			obj.Stat.lrGLM.outcomes.rew = intersect(find(lTBT > catBounds(3)), find(lTBT <= catBounds(4)));
			outcomeBT(obj.Stat.lrGLM.outcomes.rew) = 3;
			obj.Stat.lrGLM.outcomes.ITI = intersect(find(lTBT > catBounds(4)), find(lTBT <= catBounds(5)));
			outcomeBT(obj.Stat.lrGLM.outcomes.ITI) = 4;
			obj.Stat.lrGLM.outcomes.noLick = find(lTBT==17);
			outcomeBT(obj.Stat.lrGLM.outcomes.noLick) = 5;
		elseif strcmp(categories, 'all-linear')
			outcomeBT = nan(1, tTotal);
			obj.Stat.lrGLM.outcomes.Map = {'1 = lick-time-on-last-trial'};
			obj.Stat.lrGLM.outcomes.rxn = intersect(find(lTBT > catBounds(1)), find(lTBT <= catBounds(2)));
			outcomeBT(obj.Stat.lrGLM.outcomes.rxn) = lTBT(obj.Stat.lrGLM.outcomes.rxn);
			obj.Stat.lrGLM.outcomes.early = intersect(find(lTBT > catBounds(2)), find(lTBT <= catBounds(3)));
			outcomeBT(obj.Stat.lrGLM.outcomes.early) = lTBT(obj.Stat.lrGLM.outcomes.early);
			obj.Stat.lrGLM.outcomes.rew = intersect(find(lTBT > catBounds(3)), find(lTBT <= catBounds(4)));
			outcomeBT(obj.Stat.lrGLM.outcomes.rew) = lTBT(obj.Stat.lrGLM.outcomes.rew);
			obj.Stat.lrGLM.outcomes.ITI = intersect(find(lTBT > catBounds(4)), find(lTBT <= catBounds(5)));
			outcomeBT(obj.Stat.lrGLM.outcomes.ITI) = lTBT(obj.Stat.lrGLM.outcomes.ITI);
			obj.Stat.lrGLM.outcomes.noLick = find(lTBT==17);
			outcomeBT(obj.Stat.lrGLM.outcomes.noLick) = 17;
		elseif strcmp(categories, 'lin-cat')
 			%error('Model seems to be working, but results are puzzling. Go through and evaluate, then also try putting the times in categories directly. Also try normalizing the movement times to remove non-stationarity?')
			outcomeBTtimes = nan(1, tTotal);
			outcomeBT = nan(1, tTotal);
			obj.Stat.lrGLM.outcomes.Map_times = {'1 = lick-time-on-last-trial'};
			obj.Stat.lrGLM.outcomes.Map_outcome = {'1 = rxn', '2 = early', '3 = rew', '4 = ITI', '5 = noLick'};
			obj.Stat.lrGLM.outcomes.rxn = intersect(find(lTBT > catBounds(1)), find(lTBT <= catBounds(2)));
			outcomeBTtimes(obj.Stat.lrGLM.outcomes.rxn) = lTBT(obj.Stat.lrGLM.outcomes.rxn);
			outcomeBT(obj.Stat.lrGLM.outcomes.rxn) = 1;
			obj.Stat.lrGLM.outcomes.early = intersect(find(lTBT > catBounds(2)), find(lTBT <= catBounds(3)));
			outcomeBTtimes(obj.Stat.lrGLM.outcomes.early) = lTBT(obj.Stat.lrGLM.outcomes.early);
			outcomeBT(obj.Stat.lrGLM.outcomes.early) = 2;
			obj.Stat.lrGLM.outcomes.rew = intersect(find(lTBT > catBounds(3)), find(lTBT <= catBounds(4)));
			outcomeBTtimes(obj.Stat.lrGLM.outcomes.rew) = lTBT(obj.Stat.lrGLM.outcomes.rew);
			outcomeBT(obj.Stat.lrGLM.outcomes.rew) = 3;
			obj.Stat.lrGLM.outcomes.ITI = intersect(find(lTBT > catBounds(4)), find(lTBT <= catBounds(5)));
			outcomeBTtimes(obj.Stat.lrGLM.outcomes.ITI) = lTBT(obj.Stat.lrGLM.outcomes.ITI);
			outcomeBT(obj.Stat.lrGLM.outcomes.ITI) = 4;
			obj.Stat.lrGLM.outcomes.noLick = find(lTBT==17);
			outcomeBTtimes(obj.Stat.lrGLM.outcomes.noLick) = 17;
			outcomeBT(obj.Stat.lrGLM.outcomes.noLick) = 5;

		elseif strcmp(categories, 'e/l')
			error('Not implemented')
			outcomeBT = num2cell(nan(1, tTotal));
			obj.Stat.lrGLM.outcomes.early = intersection(find(lTBT > catBounds(1)), find(lTBT <= catBounds(2)));
			obj.Stat.lrGLM.outcomes.late = intersection(find(lTBT > catBounds(2)), find(lTBT <= catBounds(3)));
		end
		% 
		% 	Now fill in X (d x t)
		% 
		if strcmp(categories, 'default')
			for iHx = 1:nHx
				alignedHx = outcomeBT(tStart - iHx:end-iHx);
				for iCat = 1:numel(obj.Stat.lrGLM.outcomes.Map)
					X(iCat*iHx, alignedHx == iCat) = 1;
				end
			end
		elseif strcmp(categories, 'all-linear')
			for iHx = 1:nHx
				alignedHx = outcomeBT(tStart - iHx:end-iHx);
				for iCat = 1:numel(obj.Stat.lrGLM.outcomes.Map)
					X(iCat*iHx, :) = alignedHx;
				end
			end
		elseif strcmp(categories, 'lin-cat')
			xIdx = 1;
			for iHx = 1:nHx
				alignedHx = outcomeBTtimes(tStart - iHx:end-iHx);
				X(xIdx, :) = alignedHx;
				xIdx = xIdx + 1;
			end
			for iHx = 1:nHx
				alignedHx = outcomeBT(tStart - iHx:end-iHx);
				for iCat = 1:numel(obj.Stat.lrGLM.outcomes.Map_outcome)
					X(xIdx, alignedHx == iCat) = 1;
                    xIdx = xIdx + 1;
				end
			end
		else
			error('Not implemented');
        end
        %
        %   Add x0
        %
        X(end+1, :) = 1;
        d = d + 1;
		% 
		% 	Specify a, the y-observed (1 x t)
		% 
		a = lTBT(tStart:end);
		% 
		% 	Calculate the weights on each feature with regression.
		% 
		if xVstyle == false
			if strcmpi(Mode, 'linear')
				disp('Calculating linear fit of multi-hot features...')
				th = (X*X.'+lam.*eye(d))\X*a.';
				% 
				% 	Return the yFit
				% 
				yFit = obj.calcYfit(th, X);
				% 
			elseif strcmpi(Mode, 'NLL')
				disp('Calculating NLL fit of multiple sigmoid features...')
				error('Not Implemented')

	        end
	        figure, plot(tStart:numel(obj.GLM.cue_s), a, '-o', 'DisplayName', 'Lick Times'), hold on, plot([tStart:numel(obj.GLM.cue_s)], yFit, '-o', 'DisplayName', 'Prediction (yFit)')
	        legend('show')
	        xlabel('Trial #')
	        ylabel('lick time (s)')
	        %
	        %   Get stats
	        %
	        % [meanrsq, ~] = obj.rSquared(a, mean(a).*ones(size(a)));
	        % [rsq, ~] = obj.rSquared(a, yFit);
	        % obj.Stat.lrGLM.rsqFit = rsq;
	        % obj.Stat.lrGLM.rsqAmean = meanrsq;
			obj.Stat.lrGLM.meanAloss = 1/numel(a)*sum((a - mean(a)).^2);
			obj.Stat.lrGLM.modelSquaredLoss = 1/numel(a)*sum((a - yFit).^2);
	        disp('*************** STATS ****************')
	        disp(['**   MSE[mean(a)] = ' num2str(obj.Stat.lrGLM.meanAloss), '    **'])
	        disp(['**   MSE(yFit) = ' num2str(obj.Stat.lrGLM.modelSquaredLoss), '    **'])
	        disp(['**   Model Improvement (delta MSE) = ' num2str(obj.Stat.lrGLM.modelSquaredLoss-obj.Stat.lrGLM.meanAloss), '    **'])
        elseif strcmp(xVstyle, 'leave1out')
        	[th, X] = obj.leaveOneOutXValidation(X, a, d, lam, 'lagRegression', nHx);
        	yFit = th.'*X;
    	end
	end



	function [thset, Xset, aset, yFit] = baselineGLM(obj, windows, nHx, lam, shuffle_on, plot_on, XV)
		% 
		%	Regression model with the following characteristics: 	
		% 
		% 	yi = mean baseline within each window - n(# windows)
		% 
		% 	Xi = {
		% 		lick kernel -- just # of licks present (since predicitng a scalar)
		% 		EMG kernel -- just # of emg events present (since predicitng a scalar)
		% 		valence = [flick time - 3.3333] -- n(nHx # of trials back to look)
		% 		time of lick on next trial
		% 		}
		% 
		% 
		% 	A general note on indexing:
		% 		We will create a dataset at the beginning of everything, and then we will index for all the trials in that set.
		% 
		% 
		% 
		% 	Initialize all the inputs...			
		% 
		if nargin < 7
			XV = true;
		end
		if nargin < 6
			plot_on = true;
		end
		if plot_on
			disp('~~~~~~~~~~ BASELINE GLM ~~~~~~~~~~~')
			disp(' ')
		end
		if nargin < 5
			shuffle_on = false;
		end
		if shuffle_on && plot_on
			disp('----------------Shuffling trials!!!!!!!!!!!!!! Fit not expected to work!-----------------')
		end
		if nargin < 2
			windows = {[1,100], [100,1000]};
		end
		if numel(windows) > 1
			warning('Not prepared to do multiple windows, check on this')
		end
		if nargin < 3
			nHx = 1;
		end
		if nargin < 4
			lam = 0.0001;
			warning('lam = 0.0001, Model may overfit')
		end
		% 
		% 	Mode for running...
		% 
		yType = 'nTime'; % 'nTime, 'nBaseline', 'nOutcome'
		if strcmpi(yType, 'nTime')
			distrib = 'normal'; %'normal', 'inv-gauss', 'gamma'
			rectifydFF = false;
			movingBaseline = true;
			nTmoving = 30;
			dFFmultiplier = 10; 
			killMissingData = true;
		else
			distrib = 'normal';
			rectifydFF = false;
			movingBaseline = false;
			dFFmultiplier = 10;
			killMissingData = false;
		end
		if plot_on
			disp(['yType = ' yType])
			disp(' ')
		end
		% 
		zScoreFeaturesOn = false;
		% 
		%	Features to use... 
		% 
		useTrialRange = true;
		nConsecNoLicksToCutOff = 3;	% validated for nBaseline
		trialRange = obj.getTrialRangeSansNoLicks(nConsecNoLicksToCutOff); % gets [start, end] where there's a max of nConsecNoLicksToCutOff consecutive nolick trials
		% 
		use_x0 = true; % verified: +/-shuffle, nBaseline
		use_n_k_baselines = false; % verified: +/-shuffle, nBaseline
		use_broad_baselines = true; % verified: +/-shuffle, nBaseline
		if use_broad_baselines
			broadBaselineWindow = {[1,5000]};
			if plot_on, disp(['	BroadBaselineWindow =' mat2str(broadBaselineWindow{1})]), end
		else
			broadBaselineWindow = windows;
		end
		use_cat_hx = false; % verified: +/-shuffle, nBaseline
		use_multicat_hx = false; % verified: +/-shuffle, nBaseline
		use_multicat_noNoLick_hx = false;
		use_multicat_abridged_hx = false; % verified: +/-shuffle, nBaseline
		use_future_cat110 = false; % verified: +/-shuffle, nBaseline
		use_future_cat_onehot = false; % seems ok: +/-shuffle, nBaseline
		use_excluded_trials = false; % we will make an n-k onehot feature for excluded trials, presumed to be grooming...

		%----------------------------------------------------
		% 
		% 	RESET Containers
		% 
		obj.Stat.lrGLM = {};
		obj.GLM.flush = {};
		obj.Stat.baselineGLM.FeatureMap = {};
		aset = {};
		Xset = {};
		thset = {};
		yFit = {};
		% ----------------------------------------------------
		% 
		% 	Stamp it!
		% 
		obj.GLM.flush.Mode = {'baselineGLM', ['nHx = ' num2str(nHx)], ['windows = ' windows], ['lam = ' num2str(lam)], datestr(now)};
		% 
		% 	Initialize position elements
		% 
		obj.GLM.pos.lampOff = obj.getXPositionsWRTgfit(obj.GLM.lampOff_s);
		obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);
		obj.GLM.pos.lick = obj.getXPositionsWRTgfit(obj.GLM.lick_s);
		% % 
		% %  Rectify EMG
		% % 
		% EMG = abs(obj.GLM.emgFit);
  %       % 
  %       % 	Threshold and get stamps
  %       % 
  %       aboveT = find(EMG(2:end) > 2*std(EMG));
  %       threshd = aboveT(ismember(aboveT, find(EMG(1:end-1) < 2*std(EMG))));
  %       % 
  %       % 	Get timestamps of these events in sec...
  %       % 
  %       timestamps_s = obj.GLM.emgTimes(threshd);
  %       obj.GLM.EMGdelta_s = timestamps_s;
  %       obj.GLM.pos.EMGdelta = obj.getXPositionsWRTgfit(timestamps_s);
        % ------------------------------------------------------------------------------------------------------
		% 
		% 	Get trial to start on (can't use any for which we don't have enough Hx)
		% 
		if useTrialRange
			% tStart = nHx+trialRange(1);
			tTotal = trialRange(2) - trialRange(1) + 1;
			aElements = tTotal - nHx;
		else
			trialRange = [1,numel(obj.GLM.pos.lampOff)];
			% tStart = nHx+1;
			tTotal = numel(obj.GLM.cue_s);
			aElements = tTotal - nHx;
		end
		% 
		% 	Set up lTBT in the range of the dataset...
		% 
		lTBT = 17*ones(1, numel(obj.GLM.cue_s)); 
		lTBT(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
		% 
		% 	Now trim it
		% 
		lTBT = lTBT(trialRange(1):trialRange(2));
		obj.Stat.lrGLM.lTBT = lTBT;
		% 
		% 	Now for each window...
		% 
		for iWin = 1:numel(windows)	
			%------------------------------------------------------------------------- 
			% 
			%	Set up the y dataset... 
			% 
			%-------------------------------------------------------------------------
			% 
			% 	In general, we will create datasets limited to the trial range we want to include. 
			% 	Then, we will further exclude trials after that...
			% 
			%	Start by creating baselinedFF for all trials and nBaselineDFF for all trials
			% 		use baselineDFF for n-k and use nBaselineDFF for prediction baseline
			% 			broadbaselinewindow^          window^
			% 
			baselineDFF_positions_L = obj.GLM.pos.lampOff - broadBaselineWindow{iWin}(end);
			baselineDFF_positions_R = obj.GLM.pos.lampOff - broadBaselineWindow{iWin}(1);

			nBaselineDFF_positions_L = obj.GLM.pos.lampOff - windows{iWin}(end);
			nBaselineDFF_positions_R = obj.GLM.pos.lampOff - windows{iWin}(1);
			
			baselineDFF = nan(1, tTotal);
			nBaselineDFF = nan(1, tTotal);
			for iTrial = trialRange(1):trialRange(2)
				baselineDFF(iTrial) = dFFmultiplier*median(obj.GLM.gfit(baselineDFF_positions_L(iTrial):baselineDFF_positions_R(iTrial)));
				nBaselineDFF(iTrial) = dFFmultiplier*median(obj.GLM.gfit(nBaselineDFF_positions_L(iTrial):nBaselineDFF_positions_R(iTrial)));
			end
			if rectifydFF
				minDFF = min([baselineDFF, nBaselineDFF]);
				baselineDFF = baselineDFF + minDFF;
				nBaselineDFF = baselineDFF + minDFF;
			elseif zScoreFeaturesOn
				baselineDFF = obj.zScoreVector(baselineDFF);
				nBaselineDFF = obj.zScoreVector(nBaselineDFF);
			end
			% 
			%---------------------------------------------------------------------------
			% 	Handle shuffling
			% --------------------------------------------------------------------------
			if shuffle_on
				% 
				% 	If we are shuffling, we will just mix up all trials before handling anything more complicated
				% 
				shuffleIdx = randperm(tTotal,tTotal);
				baselineDFF = baselineDFF(shuffleIdx);
				nBaselineDFF = nBaselineDFF(shuffleIdx);
				lTBT = lTBT(shuffleIdx);
			end
			% 
			% 	Now, create the y-dataset...
			% 		Here, we just trim off the first nHx trials from our consideration to make sure we have enough history terms
			% 
			if strcmp(yType, 'nBaseline')
				a = nBaselineDFF(nHx+1:end);
			elseif strcmp(yType, 'nTime')
				a = lTBT(nHx+1:end);
			elseif strcmp(yType, 'nOutcome')
				error('Not implemented!')
			else
				error('y-type is not properly defined')
			end
			% ------------------------------------------------------------------------
			% 
			% 	Handle Missing Data
			% 		If no-licks present, may wish to exclude these trials from a and X, 
			% 		although we will leave their influence on hx terms
			% ------------------------------------------------------------------------
			if killMissingData 
				if strcmp(yType, 'nTime')
					aIdxs = 1:aElements;	% this is used to assign features to X that match the trialNum in a
					missingTrials = find(a == 17);
					nMissingTrials = numel(missingTrials);
					a(missingTrials) = [];
					aIdxs(missingTrials) = [];
					aElements = aElements - nMissingTrials;
            	else
					error('Not Implemented')
				end
			else
				missingTrials = [];
				nMissingTrials = 0;
				aIdxs = 1:aElements;
			end
			% -----------------------------------------------------------------------
			% 
			% 	Get Feature Map
			% 
			% -----------------------------------------------------------------------
			featuremapIdx = 1; 
			d = 0;
			if use_x0
				obj.Stat.baselineGLM.FeatureMap{featuremapIdx} = {'baseline offset x0'};
				featuremapIdx = featuremapIdx + 1; 
				d = d+1;
			end
			if strcmp(yType, 'nTime')
				obj.Stat.baselineGLM.FeatureMap{featuremapIdx} = {'baseline trial n: med dF/F'};
				nTrialBaselineIdx0 = featuremapIdx; 
                featuremapIdx = featuremapIdx + 1;
				d = d+1;
			end
			if use_future_cat110 
				obj.Stat.baselineGLM.FeatureMap{featuremapIdx} = {'cat next: -1e, +1l, 0ITI'};
				futureIdx = featuremapIdx;
                featuremapIdx = featuremapIdx + 1;
				d = d+1;
			end
			if use_future_cat_onehot
				obj.Stat.baselineGLM.FeatureMap{featuremapIdx} = {'cat next: rxn/early'};
				futCatStart0 = featuremapIdx-1;	
				futureIdx = featuremapIdx;
                featuremapIdx = featuremapIdx + 1;
				d = d+1;
				obj.Stat.baselineGLM.FeatureMap{featuremapIdx} = {'cat next: rew/iti'};
				futureIdx = featuremapIdx;
                featuremapIdx = featuremapIdx + 1;
				d = d+1;
				obj.Stat.baselineGLM.FeatureMap{featuremapIdx} = {'cat next: nolick'};
				futureIdx = featuremapIdx;
                featuremapIdx = featuremapIdx + 1;
				d = d+1;
			end
			if use_n_k_baselines
				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['baseline n-'  num2str(iHx) ' : med dF/F']};
				end
				nkBaselineStart0 = featuremapIdx-1;	
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;
			end
			if use_cat_hx
				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['categorical trial(-' num2str(iHx) ') +early, -late, 0ITI']};
				end
				catHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;
			end
			if use_multicat_hx
				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['rxn trial(-' num2str(iHx) ') +1rxn, 0else']};
				end
				rxnCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;

				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['early trial(-' num2str(iHx) ') +1e, 0else']};
				end
				earlyCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;

				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['rew trial(-' num2str(iHx) ') +1rew, 0else']};
				end
				rewCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;

				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['iti trial(-' num2str(iHx) ') +1iti, 0else']};
				end
				itiCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;

				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['nolick trial(-' num2str(iHx) ') +1nl, 0else']};
				end
				nolickCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;
			end
			if use_multicat_abridged_hx 
				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['rxn/early trial(-' num2str(iHx) ') +1e, 0else']};
				end
				rxnEarlyCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;

				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['rew/ITI trial(-' num2str(iHx) ') +1rew, 0else']};
				end
				rewITICatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;

				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['nolick trial(-' num2str(iHx) ') +1nl, 0else']};
				end
				nolickCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;
			end
			if use_multicat_noNoLick_hx
				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['rxn/early trial(-' num2str(iHx) ') +1e, 0else']};
				end
				rxnEarlyCatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;

				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['rew/ITI trial(-' num2str(iHx) ') +1rew, 0else']};
				end
				rewITICatHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;
			end
			if use_excluded_trials
				for iHx = 1:nHx
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx-1+iHx} = {['excluded trial(-' num2str(iHx) ') +1e, 0else']};
				end
				excludedHxStart0 = featuremapIdx-1;
				featuremapIdx = featuremapIdx + nHx;
				d = d+nHx;
			end
			if movingBaseline
				if killMissingData
					nvalidtrials = numel(find(lTBT ~=17));
				else
					nvalidtrials = numel(lTBT);
				end
				nbins = ceil(nvalidtrials/nTmoving);
				for ibin = 1:nbins
					obj.Stat.baselineGLM.FeatureMap{featuremapIdx+ibin-1} = {['moving baseline t' num2str((ibin-1)*nTmoving+1) '-' num2str((ibin)*nTmoving)]};
				end
				mBStart0 = featuremapIdx-1;	
                featuremapIdx = featuremapIdx + nbins;
				d = d+nbins;
			end
			%-------------------------------------------------------------
			% 
			% 	Initialize and fill the design Matrix
			% 
			% ------------------------------------------------------------
			X = zeros(d, aElements);
			%
	        %   Add x0
	        %
	        if use_x0
		        X(1, :) = 1;	
	        end
	        if strcmp(yType, 'nTime')
		        X(nTrialBaselineIdx0, :) = baselineDFF(nHx+aIdxs);
	        end
	        if use_cat_hx || use_future_cat110
	        	warning('check this')
	            pmCatlTBT = lTBT;
	            pmCatlTBT(lTBT < 3.333) = -1;
	            pmCatlTBT(lTBT >= 3.333) = 1; 
	            pmCatlTBT(lTBT > 7) = 0;
	            obj.Stat.lrGLM.pmCatlTBT = pmCatlTBT;
	        end
	        if use_future_cat110
	        	%
				% 	This is +1/-1/0 future category
				% 
				X(futureIdx, :) = pmCatlTBT(nHx+aIdxs);
			end
			if use_future_cat_onehot
				%
				% 	This is one-hot future category
				% 
				m = zeros(size(lTBT));
				m(lTBT < 3.333) = 1;
				X(futCatStart0+1, :) = m(nHx+aIdxs);

				m = zeros(size(lTBT));
				m(lTBT >= 3.333 & lTBT < 17) = 1;
				X(futCatStart0+2, :) = m(nHx+aIdxs);

				m = zeros(size(lTBT));
				m(lTBT == 17) = 1;
				X(futCatStart0+3, :) = m(nHx+aIdxs);
			end			
			for iHx = 1:nHx
				if use_n_k_baselines
                    X(nkBaselineStart0+iHx, :) = baselineDFF(nHx+aIdxs - iHx);
				end
				if use_cat_hx
					% 
					% 	+1/-1/0 feature
					% 
					X(catHxStart0+iHx, :) = pmCatlTBT(nHx+aIdxs - iHx);
				end
				if use_multicat_hx
					m = zeros(size(lTBT));
					m(lTBT < 0.7) = 1;
					X(rxnCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);

					m = zeros(size(lTBT));
					m(lTBT >= 0.7 & lTBT < 3.333) = 1;
					X(earlyCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);

					m = zeros(size(lTBT));
					m(lTBT >= 3.333 & lTBT < 7) = 1;
					X(rewCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);
					
					m = zeros(size(lTBT));
					m(lTBT >= 7 & lTBT < 17) = 1;
					X(itiCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);

					m = zeros(size(lTBT));
					m(lTBT == 17) = 1;
					X(nolickCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);
				end
				if use_multicat_abridged_hx
                    m = zeros(size(lTBT));
					m(lTBT < 3.333) = 1;
					X(rxnEarlyCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);

					m = zeros(size(lTBT));
					m(lTBT >= 3.333 & lTBT < 17) = 1;
					X(rewITICatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);

					m = zeros(size(lTBT));
					m(lTBT == 17) = 1;
					X(nolickCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);
				end
				if use_multicat_noNoLick_hx
					m = zeros(size(lTBT));
					m(lTBT < 3.333) = 1;
					X(rxnEarlyCatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);

					m = zeros(size(lTBT));
					m(lTBT >= 3.333 & lTBT < 17) = 1;
					X(rewITICatHxStart0+iHx, :) = m(nHx+aIdxs - iHx);
				end
				if use_excluded_trials
					m = zeros(size(lTBT));
					m(obj.iv.exclusions_struct.Excluded_Trials) = 1;
					% 
					% 	Trim down again
					% 
					m = m(trialRange(1):trialRange(2));
					X(excludedHxStart0+iHx, :) = m(nHx+aIdxs - iHx);
				end
			end
			if movingBaseline
				for ibin = 1:nbins
					if ibin ~=nbins
						X(mBStart0+ibin, (ibin-1)*nTmoving+1:(ibin)*nTmoving) = 1;
					else
						X(mBStart0+ibin, (ibin-1)*nTmoving+1:end) = 1;
					end
				end
			end
			% 
			% 	Calculate the weights on each feature with regression.
			% 
			if strcmp(distrib, 'normal') 
				if XV
		        	[th, X] = obj.leaveOneOutXValidation(X, a, d, lam, 'baselineGLM', nHx, [], [], plot_on, distrib);
	        	else
	        		% 
					% 	Calculate fit
					% 
	        		th = (X*X.'+lam.*eye(d))\X*a.';
	    		end
	        	yFiti = th.'*X;
        	elseif strcmp(distrib, 'inv-gauss')
        		if XV
        			warning('untested')
        			[th, X] = obj.leaveOneOutXValidation(X, a, d, lam, 'baselineGLM', nHx, [], [], plot_on, distrib);
                    yFiti = glmval(th,X',-2, 'constant', 'off')';
    			else
    				warning('untested')
	        		[th,~,stats] = glmfit(X',a,'inverse gaussian', 'constant', 'off');
	        		yFiti = glmval(th,X',-2, 'constant', 'off');
        		end
        	elseif strcmp(distrib, 'gamma')
        		if XV
        			warning('untested')
        			[th, X] = obj.leaveOneOutXValidation(X, a, d, lam, 'baselineGLM', nHx, [], [], plot_on, distrib);
                    yFiti = glmval(th,X','reciprocal', 'constant', 'off')';
    			else
    				warning('untested')
	        		[th,~,stats] = glmfit(X',a,'gamma', 'constant', 'off');
	        		yFiti = glmval(th,X','reciprocal', 'constant', 'off');
        		end
    		else
    			error('not implemented');
    		end 

			aset{iWin} = a;
			Xset{iWin} = X;
			thset{iWin} = th;
			yFit{iWin} = yFiti;
        end
    end


	function [thShSet, thShMean, thShCI, thShStd, th, p, X, a, yFit] = shuffleBaselineGLM(obj, nShuffle, win, nHx, lam)
		thShSet = [];
		for iShuffle = 1:nShuffle
			if rem(iShuffle,5) == 0
				disp(['Shuffle #', num2str(iShuffle)])
			end
			[thset, ~, ~, ~] = obj.baselineGLM(win, nHx, lam, true, false, false);
			thShSet(:,iShuffle) = thset{1, 1};
		end
		% 
		% 	Get mean shuffled thSet and other CIs...
		% 
		thShMean = mean(thShSet, 2);
		thShCI = obj.CI95(thShSet);
        if nShuffle > 1
    		thShStd = std(thShSet');
            thShStd = thShStd';
        else
            thShStd = 0;
        end
		% 
		% 	Get the real fit....
		% 
		[th, X, a, yFit] = obj.baselineGLM(win, nHx, lam, false, true, true);
		% 
		%	Calculate p values for each coefficient... 
		% 
		n = nShuffle + 1;
		for ith  = 1:numel(th{1,1})
			nMoreExtreme(ith, 1) = sum(th{1,1}(ith) < thShSet(ith, :));
		end 
		p = nMoreExtreme./n;
		pmin = 1/n;
		disp('    ')
		disp(['pmin = ' num2str(pmin)])
		disp(mat2str(round(p,2)))
		% 
		% 	Plot all the th's shuffled, their CIs, etc, and the actual fit
		% 
		figure
		ax = subplot(1,1,1);
        hold on
    	idx = 1 : numel(obj.Stat.baselineGLM.FeatureMap);
    	h0 = plot(idx, zeros(size(idx)), 'k-');
        h1 = plot(idx, (thShSet(idx, :)), 'co'); %flipud
        h2 = plot(idx, (thShCI(idx, 2)), 'ro-', 'DisplayName', 'Upper Shuffled CI'); %flipud
        h3 = plot(idx, (thShCI(idx, 1)), 'ro-', 'DisplayName', 'Lower Shuffled CI'); %flipud
        h4 = plot(idx, (thShMean(idx)), 'ko-', 'DisplayName', 'Ave Shuffled th'); %flipud
        h5 = plot(idx, thShMean(idx)-thShStd(idx), 'bo-', 'DisplayName', 'Shuffled th STD'); %flipud
        h6 = plot(idx, thShMean(idx)+thShStd(idx), 'bo-'); %flipud
        h7 = plot(idx, th{1,1}(idx), 'go-', 'DisplayName', 'Fit th - all data');
        if numel(p<0.05 | p>0.95) > 0
        	h8 = plot(idx(p<0.05 | p>0.95), th{1,1}(idx(p<0.05 | p>0.95)), 'k*');
    	end
    	legend([h2,h3,h4, h5, h7])
        set(ax,'XTick',idx);
    	for ilabel = 1:numel(obj.Stat.baselineGLM.FeatureMap)
	        ax.XAxis.TickLabels{ilabel} = char(obj.Stat.baselineGLM.FeatureMap{ilabel});
        end
		ax.XAxis.TickLabelRotation = 45;
        title('Fit parameters...')

	end


%-----------------------------------------------------------------------
% 
% 	METHODS: GLM Helper Methods (3/27/19 based on Gelman/Hill)
% 
% ----------------------------------------------------------------------
		function [se_model, se_th, CVmat, signifCoeff] = standardErrorOfModelAndTh(obj, XtX, th, yActual, yFit, lambda)
			% 
			% 	Standard error of the model:
			% 
			% 	se_model = sqrt(variance of model) = sqrt((yActual-yFit)^2)
			% 
			se_model = sqrt(sum((yActual-yFit).^2./numel(yFit)));
			%  Not sure why I changed to this, it should be the above I think.
						% se_model = sum(yActual - yFit);
			% 
			% 	Standard Error of Coefficients
			% 	
			% % 	se_th = se_model*(XtX_1*I).^0.5 -- the sqrt of the diagonal elements of covariance matrix
			% % 	
			% se_th = se_model.*(diag(XtX_1)).^0.5;
			% 
			% 	Changinging to Chicha method for general lambda
			% 
			% 	CVmat is usually XtX^-1, and this will converge to that when lambda = 0
			% 
			CVmat = (XtX+lambda*eye(size(XtX)))^-1*XtX*(XtX+lambda*eye(size(XtX)))^-1;
			% 
			% 	Standard Error of Coefficients
			% 
			se_th = se_model.*diag(CVmat).^.5;
			% 
			% 	The covariance matrix can be used for predictive simulations in the 
			%			future, as well as to do correlations between predictors
			% 
			% 	p-value of ths:
			% 		If coeff is > 2std from zero, then it's a significant contributer to model
			% 		Means we are 95% sure of the SIGN of the coefficient and that the estimate is stable
			% 		not just an artifact of small sample size
			% 
			% 	However, even if coeff not significant, doesn't mean isn't important to model
			% 
			distFromZero = abs(th) - 2*abs(se_th);
			signifCoeff = distFromZero > 0;
		end
		function [Resid, std_Resid, explainedVarianceR2] = getModelResidualsAndR2(obj, yActual, yFit, th)
			% 
			% 	Resiuduals:
			%			ri = yi - xi*thi
			%		The differences between model and fitted data. By definition, 
			%			uncorrelated with all predictors in model
			%		If model has constant x0, then must be uncorrelated with constant
			%			Thus mean(resid) = 0, should follow a normal distribution
			%		Use residuals to diagnose problems with the model
			% 
			% 	Residual std: seems to be the same as the model standard error
			% 			std_Resid = sqrt(sum(Resid.^2/(numel(yActual)-numel(th))))
			% 		Summarizes the scale of the residuals - the average distance of each point 
			% 			in the fit to the actual data, IOW the margin of error of the fit
			% 				e.g., if std_Resid = 0.001 dF/F, we can predict the dF/F signal to 
			% 				within 0.001 dF/F at this point in the timeseries
			% 		(n-k) = DOF of model = number of points in timeseries - number of th coefficients
			% 
			% 		Uncertainty in this std is proportional to a Chi^2 distribution with (n-k) DOF
		    % 			This will be used in predictive simulations
			% 
			% 	HOW TO INTERPRET MODEL:
			%		1. Are residuals generally small wrt signal of interest?
			%		2. Is std of residuals small enough that we can detect an effect
			% 			For ex, std of > 0.01 dF/F would not be very useful if ramps on order of 0.01 dF/F
			% 		3. Do residuals have mean = 0 and follow normal distribution?
			% 		4. How much variance are we explaining compared to other models?
			% 
			Resid = yActual - yFit;
			% 
			% 	Std of Residuals
			% 
			std_Resid = sqrt(sum(Resid.^2)./(numel(yActual) - numel(th)));
			% 
			% 	Variance explained by model (R^2)
			% 
			std_yActual = std(yActual);
			explainedVarianceR2 = 1 - std_Resid^2/std_yActual^2;
		end



%-----------------------------------------------------------------------
% 
% 	METHODS: Nested GLM
% 
% ----------------------------------------------------------------------




		function [th, X, a, yFit, x, xValidationStruct, CVmat] = nestedGLM(obj, cannedStyle, trimming, lam, th0_on, Events, x_style, basis, smoothing)
		suppressPlot = true;
		% 
		%	nestedGLM: takes gfit photometry (2xt+ array, because we need to keep timestamps in 2nd row to make sure we align correctly),
		% 							mfit movement, (2xt+ array, because we need to keep timestamps in 2nd row to make sure we align correctly)
		% 							cue times, 
		% 							lamp off times, 
		% 
		% 	a = yreal = photometry timeseries (1xt)
		% 	p = yprediction = sum(conv(x_events, th*basis)) --- note each x_events timeseries is a one-hot or box-car like thing
		% 
		% 	L(th) = sum_i(a - p)^2 + ||th||^2
		% 	dL/dth(th) = sum_i(2*(a-p)*-) + 2*th  				<---------- Check forumulas
		% 
		% 
		% 	dF/F:	-1	-1	2	3	-4	-1	-1	-1	2	1	0 	-1	-1	2	-5	-1	-1
		% 	move:	0	1	-1	-1	0	1	1	0	0	0	0	0	1	1	-1	0	0
		% 	cue:	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	
		% 	flick:	0	0	0	1	0	0	0	0	0	0	0	0	1	0	0	0	0
		% 	etime:	0	0	1	0	0	0	0	0	1	1	1	1	0	0	0	0	0
		% 
		% 
		% 	INPUTS:
		% 
		% 		cannedStyle:	Uses a preset bunch of events and features...
		% 
			% STDmultiplier = 1;
			STDmultiplier = obj.GLM.STDmultiplier;
			cannedStyleDict = {'cue_flick_rampdelta_MOVEdelta', 'cue_flick_rampdelta', 'BEST_cue_flick', 'BEST_cue_flick_MOVEdelta', 'BEST_cue_flick_boxes_MOVEdelta', 'BEST_cue_flick_boxes_vt_MOVEdelta', 'BEST_cue_flick_EMG', 'BEST_cue_flick_boxes_EMG', 'BEST_cue_flick_boxes_vt_EMG', 'cue_firstlicktype', 'cue_flick_timing', 'cue_flick_EMG', 'EMG', 'timing', 'cue_flick_timing_EMG', 'cue_flick_ramps_EMG', 'EMGdelta', 'timing_ramps', 'ramp-convolution', 'cue_flick_rampdelta_EMG', 'test_ssStretch', 'autoregression', 'tdt', 'BEST_cue_flick_tdt', 'BEST_cue_flick_MOVEdelta_tdt', 'BEST_cue_flick_boxes_MOVEdelta_tdt', 'BEST_cue_flick_boxes_vt_MOVEdelta_tdt', 'cue_flick_rampdelta_MOVEdelta_tdt', 'self'};
		% 
		% 		Events:		This will be a cell array each entry is an event.
		% 					movement: the processed movement timeseries (no need to convolve or can just minimally convolve)
		% 						NOTE: 
		% 					timestamps of events -- x-style will transform these into simplified x-representations
		% 					paired timestamps -- x-style will convert these into boxcars or ramps etc between each consecutive pair, odd elements are 1st
		% 
		% 		x_style:	This cell array of cells determines how we will represent the events
		% 					{'none', samples_per_ms}-- use raw signal, but convert to same shape as photometry as needed
		% 					{'blur', width, samples_per_ms} -- convolves with a single gaussian of width (in ms) specified -- use with movement signals
		% 					{'delta', spread = 1} -- transforms timestamps into a one-hot. If there's a spread ~= 1 (e.g., 3), then instead of 01000 --> 01110
		% 					{'boxcar'} 		-- transforms paired timestamps into boxcars of width = distance between timestamps
		% 					{'ramp'}		-- transforms paired timestamps into a ramp of width = distance between timestamps
		% 		
		% 		basis:		A cell array of basis constructor keywords:
		% 					'cue':		Mode: 'gauss', centering: 'right', width = [50ms, 100ms, 500ms, 1000ms, 5000ms], spacing: 'b-max' (spaced by quarter width), tiled to cover the 14sec maximum length of the curve in a trial
		% 					'lick':		Mode: 'gauss', centering: 'center,' width = [50ms, 100ms, 500ms, 1000ms, 5000ms], spacing: 'b-max', tiled to cover the 7sec (either side) maximum width of the curve in a trial
		%					'timing':	Mode: 'ramp' 'boxcar' or 'gauss', centering: 'center', width = [5ms, 50ms, 100ms, 500ms, 1000ms, 5000ms], spacing: 'q-max', tiled to cover 7 sec interval and more	 		
		% 
		% 
		% 		trimming:	In case we want to modify how the boundary events are selected. Right now it's lightsoff(1):lightsoff(end), but we may want to pad
		% 
		% ----------------------------------------------------------------------------------
			disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
			disp('~~~~~~~~~~~~~~~~~~~~~Nested GLM v2.6~~~~~~~~~~~~~~~~~~~~~~~')
			disp('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
			% 
			%	Reset reusables 
			% 
            obj.GLM.flush = {};
            obj.GLM.pos = {};
            obj.Stat.GLM = {};
            obj.Stat.GLM.STDmultiplier = STDmultiplier;
			% 
			%	Check the object has the appropriate data-style (needs to contain gfit) 
			% 
			if obj.GLM.Mode ~= true
				error('Nested GLM only works with GLM-compatible statsobject from version 2.x and up. (10/11/18)')
			end
			% 
			% 	Get lightsOff positions if doesn't exist
			% 
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos,'lampOff')
				obj.GLM.pos.lampOff = obj.getXPositionsWRTgfit(obj.GLM.lampOff_s);
			end
			% -----------------------------------------------------------------------------
			%						   DEFAULTS + INITIALIZATION
			% -----------------------------------------------------------------------------
			% 
			% 	LAMBDA regularization
			% 
			if nargin < 4
				lam = 0;
				warning('Model will NOT be regularized. Lambda = 0')
			end
			% 
			% SMOOTHING WINDOW
			% 
			if nargin < 9	
				smoothing = 100;
				disp(['	Smoothing with default kernel: ' num2str(smoothing) '*samples_per_ms'])
				obj.GLM.flush.smoothing = smoothing;
			else
				disp(['	Smoothing with kernel: ' num2str(smoothing) '*samples_per_ms'])
				obj.GLM.flush.smoothing = smoothing;
			end
			% 
			% CANNED STYLE 
			% 
			if nargin < 2
				cannedStyle = false;
			elseif sum(cannedStyle ~= false) && sum(contains(cannedStyleDict,cannedStyle))
				cannedStyleSheet_nestedGLMv3x8
			end
			% 
			% BASIS CONSTRUCTORS
			% 
			if nargin < 8 && sum(cannedStyle == false) || ~sum(contains(cannedStyleDict,cannedStyle))
				warning('The cell array of basis-constructor keywords was not provided. Will implement just behavioral events with defaults: cue and lick.')
				basis{1} = {'cue'};
				basis{2} = {'lick'};
				obj.Stat.GLM.eventNames = {'cue', 'flick'};
				% basis{3} = {'timing'};
            elseif ~sum(cannedStyle == false) && sum(contains(cannedStyleDict,cannedStyle))
                %
			else
				disp('	User-provided basis-constructor keywords will be used.')
			end
			% 
			% X-STYLES
			% 
			if nargin < 7 && sum(cannedStyle == false) || ~sum(contains(cannedStyleDict,cannedStyle))
				warning('No x-representation styles provided. Will use default representations and behavioral events: cue and first-lick')
				warning('Overwriting input events to match x-reps defaults!!!')
				Events = {obj.GLM.cue_s, obj.GLM.firstLick_s};
                x_style = {{'delta', 1}, {'delta', 1}};
                for istyle = 1:numel(x_style)
    				disp(['Event #' num2str(istyle), x_style{istyle}, 'basis: ' basis{istyle}])
                end
            elseif ~sum(cannedStyle == false) && sum(contains(cannedStyleDict,cannedStyle))
                %                 
			else
				disp('	User-provided x-representations will be used:')
				for istyle = 1:numel(x_style)
					disp(['Event #' num2str(istyle), x_style{istyle}, 'basis: ' basis{istyle}])
				end
			end
			% 
			% TH0
			% 
			if nargin < 5
				th0_on = true;
			end
			%	 
			% 	TRIMMING, a, t
			% 
			if nargin < 3
				disp('	Using default trimming -- chopping data at first lights-off event until 2,000,000ms.')
				trimming = [1, 2000000];
				% a = obj.GLM.gfit(obj.GLM.pos.lampOff(1):obj.GLM.pos.lampOff(end));
				obj.GLM.pos.pos1 = obj.GLM.pos.lampOff(1);
				obj.GLM.pos.pos2 = obj.GLM.pos.lampOff(1)+2000000-1;
				% obj.GLM.pos.testpos1 = obj.GLM.pos.lampOff(1)+2000000;
				% obj.GLM.pos.testpos2 = obj.GLM.pos.lampOff(1)+4000000-1;

				obj.GLM.gfit_sm = obj.smooth(obj.GLM.gfit, smoothing);

				a = obj.GLM.gfit_sm(obj.GLM.pos.pos1:obj.GLM.pos.pos2);
				a = a';
				% atest = obj.GLM.gfit_sm(obj.GLM.pos.testpos1:obj.GLM.pos.testpos2);
				% atest = atest';
				
				t_times = obj.GLM.gtimes(obj.GLM.pos.pos1:obj.GLM.pos.pos2);
				t = numel(a);
				
				obj.GLM.flush.a = a;
				% obj.GLM.flush.atest = atest;
				obj.GLM.flush.t_times = t_times;
				obj.GLM.flush.t = t;
				
			else
				if strcmp(trimming, 'trial2lick')
					[a, t_times, t] = obj.build_a_trial2lick(smoothing);
				else
					disp(['	Trimming implemented. Going from first LightsOff + ' num2str(trimming(1)), ' ms to ' num2str(trimming(2)), 'ms post lightsOff.'])
					obj.GLM.pos.pos1 = obj.GLM.pos.lampOff(1)+trimming(1);
					obj.GLM.pos.pos2 = obj.GLM.pos.lampOff(1)+trimming(2)-1;

					% obj.GLM.pos.testpos1 = obj.GLM.pos.lampOff(1)+trimming(3);
					% obj.GLM.pos.testpos2 = obj.GLM.pos.lampOff(1)+trimming(4)-1;
					
					obj.GLM.gfit_sm = obj.smooth(obj.GLM.gfit, smoothing);

					a = obj.GLM.gfit_sm(obj.GLM.pos.pos1:obj.GLM.pos.pos2);
	                a = a';
					% atest = obj.GLM.gfit_sm(obj.GLM.pos.testpos1:obj.GLM.pos.testpos2);
	    %             atest = atest';
					t_times = obj.GLM.gtimes(obj.GLM.pos.pos1:obj.GLM.pos.pos2);
					t = numel(a);
					obj.GLM.flush.a = a;
					% obj.GLM.flush.atest = atest;
					obj.GLM.flush.t_times = t_times;
					obj.GLM.flush.t = t;
					% 
					% 	Note which trials fit the range:
					% 
					error('warning this is not tested yet (below) - is used for the ssStretch method')
					obj.GLM.flush.SnTrials = find(obj.GLM.pos.cue >= obj.GLM.pos.pos1 & obj.GLM.pos.cue <= obj.GLM.pos.pos2);
					obj.GLM.flush.SnfLickIdx = obj.GLM.flush.SnTrials(ismember(obj.GLM.flush.SnTrials, obj.GLM.fLick_trial_num));
				end
			end
			% 
			disp('Initialization complete.')
			%
			% --------------------------------------------------------------------------------------
			%							Construct common basisSet
			% --------------------------------------------------------------------------------------
			% 
			%	Construct the basis set to fit the X-representations with 
			% 
			[basisSet, x_bars, basisMap, basisXaxis, basisXsingle] = cellfun(@(b_style, idx) obj.makeBasis(b_style, idx), basis, num2cell(1:numel(basis)), 'UniformOutput', 0);
			%
            %   Add the ssStretch kernel
            %
            if strcmp(obj.Stat.GLM.eventNames,'ssStretch')
                idx = contains(obj.Stat.GLM.eventNames,'ssStretch');
                obj.GLM.flush.dF2kernel = obj.makeTaylor2ndDerivVect(100, 0, round(obj.Plot.samples_per_ms));
                basisSet{idx} = obj.GLM.flush.dF2kernel{2};
                x_bars{idx} = 0;
                basisXaxis{idx} = obj.GLM.flush.dF2kernel{1};
                basisXsingle{idx} = obj.GLM.flush.dF2kernel{2};
            end             
            % 
			% 	Finalize the basisMap
			% 
			temp = basisMap{1,1};
			eventMap = [1];
			eventMapIdx = numel(basisMap{1,1})/2+1;
			if numel(basisMap) > 1
				for ibasis = 2:numel(basisMap)
					temp = vertcat(temp, basisMap{1,ibasis});
					eventMap(ibasis) = eventMapIdx;
                    if strcmp(obj.Stat.GLM.eventNames,'ramp-delta')
                        warning('We will overwrite this part of eventMap later on...') 
                    else
    					eventMapIdx = eventMapIdx + numel(basisMap{1,ibasis})/2;
                    end
                end
            else
                temp = {basisMap{1,1}{1,1}, basisMap{1,1}{1,2}};
			end
			basisMap = temp;
			obj.Stat.GLM.basisMap = basisMap;
			obj.Stat.GLM.eventMap = eventMap;	% tells us the first feature index for the next event
			obj.Stat.GLM.basisXaxes = basisXaxis;
			obj.Stat.GLM.basisXsingles = basisXsingle;
			clear temp;
			% 
			% 	Isolate the basisSet curves for each event
			% 
            nobasisEvents = find(cellfun(@(b) contains(b,'timing'), basis));
            if find(cellfun(@(b) contains(b,'EMG'), basis) & cellfun(@(b) ~contains(b,'delta'), basis))
                nobasisEvents(end+1) = find(cellfun(@(b) contains(b,'EMG'), basis));
            end
            basisEvents = find(~ismember(1:numel(basis), nobasisEvents));
			for xEvent = basisEvents
				basisCurves{xEvent} = cellfun(@(curve, idx) curve{1,2}, basisSet{1,xEvent}, num2cell(1:numel(basisSet{1,xEvent})), 'UniformOutput', 0);
            end
            if ~exist('basisCurves')
                basisCurves = {};
            end
            obj.Stat.GLM.basisCurves = basisCurves;
            obj.Stat.GLM.x_bars = x_bars;
            
			% --------------------------------------------------------------------------------------
			%							Build features for training set
			% --------------------------------------------------------------------------------------

			[X, x, d] = obj.buildFeatures(th0_on, Events, x_style, t, t_times, x_bars, nobasisEvents, basisCurves, trimming);
                            
            if size(a,2) ~= size(X,2)
                a = a';
                obj.GLM.flush.a = a;
            end
            %
            %
            %
            if obj.Stat.GLM.eventMap(end) < d && th0_on
                eventMap(end+1) = d;
				obj.Stat.GLM.eventMap(end+1) = d;
            end            
            %
            %   If we have a ramp-delta event, need to shift the eventMap
            %
            % warning('We will overwrite this part of eventMap HERE...')
            if ~isempty(find(contains(obj.Stat.GLM.eventNames,'ramp-delta')))
	            rampIdx = find(contains(obj.Stat.GLM.eventNames,'ramp-delta'));
                eventMap(rampIdx+1:end-1) = eventMap(rampIdx+1:end-1) + obj.GLM.flush.nth{rampIdx}-1;
                obj.Stat.GLM.eventMap = eventMap;	% tells us the first feature index for the next event
            end
            if ~isempty(find(contains(obj.Stat.GLM.eventNames,'stretch-time')))
            	rampIdx = find(contains(obj.Stat.GLM.eventNames,'stretch-time'));
                eventMap(rampIdx+1:end-1) = eventMap(rampIdx+1:end-1) + obj.GLM.flush.nth{rampIdx}-1;
                obj.Stat.GLM.eventMap = eventMap;	% tells us the first feature index for the next event
        	end
			
			% --------------------------------------------------------------------------------------
			%							Execute Regression...
			% --------------------------------------------------------------------------------------
			% 
			disp(['	Features complete. Initiating regression... ', datestr(now)])
			% 
			% 	--------------------------------------------------------
			% 					Analytical Solution
			% 	--------------------------------------------------------
			% 
			% if cond(X*X.') < 10^90
			try
				disp(['XX.T is pseudo-invertible! Using analytical RIDGE solution, lambda = ', num2str(lam)])
				% 
				% if matrix is invertible, we will use analytical solution
				% 
				XtX = X*X.';
				th = (XtX+lam.*eye(d))\X*a.';
				% 
				% 	Return the yFit
				% 
				yFit = obj.calcYfit(th, X);
				[se_model, se_th, CVmat, signifCoeff] = obj.standardErrorOfModelAndTh(XtX, th, a, yFit, lam);
				[Resid, std_Resid, explainedVarianceR2] = obj.getModelResidualsAndR2(a, yFit, th);
			% 
			% 	--------------------------------------------------------
			% 					Gradient Descent
			% 	--------------------------------------------------------
			% 
			catch
				disp(['XX.T NOT pseudo-invertible. Using gradient descent, lambda = ', num2str(lam)])
				[th, yFit] = obj.ridge(X, a, x, nobasisEvents, true, lam);
			end
			
			% --------------------------------------------------------------------------------------
			%							Collect Regression Stats for Training Set
			% --------------------------------------------------------------------------------------
			% 
			% 	Pass the relevant variables to obj.Stat.GLM
			% 
			obj.Stat.GLM.basisSet = basisSet;
			% obj.Stat.GLM.basisMap = basisMap;
			obj.Stat.GLM.nobasisEvents = nobasisEvents;
            
			obj.Stat.GLM.totalFeatureForEvent(basisEvents) = arrayfun(@(eventNo) obj.totalFeatureForEvent(th, eventNo, basisCurves, x_bars), basisEvents, 'UniformOutput', 0);
            obj.Stat.GLM.totalFeatureForEvent(nobasisEvents) = x(nobasisEvents);
			% 
			% 	Display the fit and parameters:
			% 
			if ~suppressPlot
				obj.plotFit(yFit, a, x, nobasisEvents);
				obj.findFeature(th, X);
			end
			% 
			% 	Display results for training set
			%
			disp('') 
			disp('============ RESULTS ============')
			obj.Stat.GLM.meanAloss = 1/numel(a)*sum((a - mean(a)).^2);
			obj.Stat.GLM.modelSquaredLoss = 1/numel(a)*sum((a - yFit).^2);
			disp(['	Training Set Squared Loss of just using mean(a) = ' num2str(obj.Stat.GLM.meanAloss)])
			disp(['	Training Set Squared Loss of GLM fit = ' num2str(obj.Stat.GLM.modelSquaredLoss)])
			% 
			% 	Return a structure of parameters to enter into xValidate:
			% 
			xValidationStruct.smoothing = smoothing;
			xValidationStruct.cannedStyle = cannedStyle;
			xValidationStruct.trainTrim = trimming;
			xValidationStruct.lam = lam;
			xValidationStruct.th0_on = th0_on;
			xValidationStruct.Events = Events;
			xValidationStruct.x_style = x_style;
			xValidationStruct.x_bars = x_bars;
			xValidationStruct.basisCurves = basisCurves;
			xValidationStruct.nobasisEvents = nobasisEvents;
			xValidationStruct.thFit = th;
			% 
			% 	Model diagnostics
			% 
			obj.Stat.GLM.th = th;
			obj.Stat.GLM.se_model = se_model;
			obj.Stat.GLM.se_th = se_th;
			obj.Stat.GLM.signifCoeff = signifCoeff;
			obj.Stat.GLM.Resid = Resid;
			obj.Stat.GLM.std_Resid = std_Resid;
			obj.Stat.GLM.explainedVarianceR2 = explainedVarianceR2;
			% 
			% 	Finally, reset the recycle so don't call it by mistake later.
			% 
			obj.GLM.flush.recycleUniformSn = false;
		end



		function [Xtest, atest, yFitTest, xtest] = xValidate(obj, xVS, trimming)
			% 
			% 	Using the xValidationStruct from nestedGLM, calculate the loss on new test data
			% 
			if strcmp(trimming, 'trial2lick')
				debugOn = true;
				uniformOn = true;
				% 
				% 	Get rid of any trials longer than 7 sec...
				% 
				samples_per_ms = obj.Plot.samples_per_ms;%round((obj.GLM.gtimes(2)-obj.GLM.gtimes(1))*1000);
				obj.GLM.pos.fLick = obj.getXPositionsWRTgfit(obj.GLM.firstLick_s);%round(1000*obj.GLM.firstLick_s*samples_per_ms)+1;
				obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue);%round(1000*obj.GLM.cue_s*samples_per_ms) + 1;
				% 
				% 	All trials with a lick...
				% 
				trialpool = obj.GLM.fLick_trial_num;
				% 
				%	Get rid of any trials longer than 7 sec from consideration... 
				% 
				% warning('need to remove >7s licks later on - do this later. 11/15/18')	Looks good 11/15/18
				% This is problematic, try removing later
				% tooLongLicks = find(obj.GLM.pos.fLick - obj.GLM.pos.cue(trialpool) > 7000);
				% trialpool(ismember(trialpool,tooLongLicks)) = [];
				% 
				% 	Shuffle the trials in each set...
				% 
				obj.GLM.flush.shuffledfLickIdx = randperm(numel(trialpool));
				obj.GLM.flush.shuffledTrials = trialpool(obj.GLM.flush.shuffledfLickIdx);
				
				if ~debugOn
					obj.GLM.flush.trialsPerSet = floor(numel(trialpool)/2);
					% obj.GLM.flush.SnfLickIdx = obj.GLM.flush.shuffledfLickIdx(1:obj.GLM.flush.trialsPerSet);
					% obj.GLM.flush.SnTrials = obj.GLM.flush.shuffledTrials(1:obj.GLM.flush.trialsPerSet);
				else
					% warning('Debug turned on - we are not randomizing trials here, and using WHOLE dataset...')
					obj.GLM.flush.trialsPerSet = floor(numel(trialpool));
					% 
					% 	DEBUG!!!!!!!!!!!!!!!! no randomization...
					% 
					obj.GLM.flush.SnfLickIdx = 1:obj.GLM.flush.trialsPerSet;
					obj.GLM.flush.SnTrials = trialpool(1:obj.GLM.flush.trialsPerSet);
				end

				obj.GLM.pos.pos1 = 1;
				obj.GLM.pos.pos2 = numel(obj.GLM.gfit);
				obj.GLM.gfit_sm = obj.smooth(obj.GLM.gfit, xVS.smoothing);
				% 
				% 	If we are selecting a more uniform distribution of trial times, let's do that now:
				% 
				if uniformOn
% 						error('IN PROGRESS........................................ 11/14/18')
					disp('*** Selecting a more Uniform Set of trials ***')
					% disp('	NOT FITTING WITH 0-1s intervals!!!!!!')
					binWindows = [0,1,2,3,4,5,6,7]; % previously [1,2,3,4,5,6,7]
					if isfield(obj.GLM, 'uniformTrialNums')
						obj.GLM.uniformTrialNums = [];
					end
					lick_tbt_trim_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrials), obj.GLM.pos.flick(obj.GLM.flush.SnfLickIdx), 'UniformOutput', 0)); 
					% lick_tbt_trim_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrials), obj.GLM.pos.fLick(obj.GLM.flush.SnfLickIdx), 'UniformOutput', 0)); 
					[N,edges] = histcounts(lick_tbt_trim_s,binWindows);
					if ~suppressPlot
						figure, subplot(1,2,1), histogram(lick_tbt_trim_s, binWindows), title('Distribution of Lick Times in Sn before Uniform operation')
					end
					% 
					% 	Ok, now that we have found number in each bin, let's go with the smallest bin and randomly select trials that fit in each category
					% 
					ntrialsToFit = min(N);
					disp(['		*** Fitting ' num2str(ntrialsToFit) ' trials from each 1s bin...'])
					nTrialsTotal = ntrialsToFit*(numel(edges)-1);
					obj.GLM.flush.SnTrialsUniform = nan(1, nTrialsTotal);
					obj.GLM.flush.SnfLickIdxUniform = nan(1, nTrialsTotal);
					for ibin = 1:numel(edges)-1
% 							warning('DEBUG
% 							HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
% 							seems ok 11/15/18
						trialIdxs = find(lick_tbt_trim_s >= edges(ibin) & lick_tbt_trim_s < edges(ibin+1));
						idxsToKeep = randperm(numel(trialIdxs),ntrialsToFit);
                        if edges(1) == 0
                            obj.GLM.flush.SnTrialsUniform(1+edges(ibin)*ntrialsToFit:ntrialsToFit+edges(ibin)*ntrialsToFit) = obj.GLM.flush.SnTrials(trialIdxs(idxsToKeep));
                            obj.GLM.flush.SnfLickIdxUniform(1+edges(ibin)*ntrialsToFit:ntrialsToFit+edges(ibin)*ntrialsToFit) = obj.GLM.flush.SnfLickIdx(trialIdxs(idxsToKeep));
                        else
                            if ibin == 1
                                obj.GLM.flush.SnTrialsUniform(1:ntrialsToFit) = obj.GLM.flush.SnTrials(trialIdxs(idxsToKeep));
                                obj.GLM.flush.SnfLickIdxUniform(1:ntrialsToFit) = obj.GLM.flush.SnfLickIdx(trialIdxs(idxsToKeep));
                            else
                                obj.GLM.flush.SnTrialsUniform(1+(ibin-1)*ntrialsToFit:ntrialsToFit+(ibin-1)*ntrialsToFit) = obj.GLM.flush.SnTrials(trialIdxs(idxsToKeep));
                                obj.GLM.flush.SnfLickIdxUniform(1+(ibin-1)*ntrialsToFit:ntrialsToFit+(ibin-1)*ntrialsToFit) = obj.GLM.flush.SnfLickIdx(trialIdxs(idxsToKeep));
                            end
                        end
					end
					[a,t,t_times, obj.GLM.flush.idx_b_t, obj.GLM.flush.idxcat] = obj.trial2lickTrim(obj.GLM.flush.SnTrialsUniform, obj.GLM.flush.SnfLickIdxUniform);
					% lick_tbt_trim_uniform_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrialsUniform), obj.GLM.pos.fLick(obj.GLM.flush.SnfLickIdxUniform), 'UniformOutput', 0)); 
					lick_tbt_trim_uniform_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrialsUniform), obj.GLM.pos.flick(obj.GLM.flush.SnfLickIdxUniform), 'UniformOutput', 0)); 
					subplot(1,2,2), histogram(lick_tbt_trim_uniform_s, binWindows), title('Distribution of Lick Times in Sn post Uniform operation')
				else
					error('THERE''S A PROBLEM WITH REMOVING THE >7s LICKS IN FOLLOWING LINE for nonuniform case - FIX THIS BEFORE PROCEEDING')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%left off here 11/14/18
					[a,t,t_times, obj.GLM.flush.idx_b_t, obj.GLM.flush.idxcat] = obj.trial2lickTrim(obj.GLM.flush.SnTrials, obj.GLM.flush.SnfLickIdx);
				end
				% 
				% 
				% 
				obj.GLM.flush.a = a;
				obj.GLM.flush.t_times = t_times;
				obj.GLM.flush.t = t;
			elseif trimming(1) > xVS.trainTrim(1) && trimming(1) < xVS.trainTrim(2) || trimming(2) > xVS.trainTrim(1) && trimming(2) < xVS.trainTrim(2)
				% 
				%	Check that trimming doesn't overlap the training set!! 
				% 
				error('Trim windows overlap with the training set. This isn''t valid for xValidation!')
			else
				% 
				%	Execute trimming for the test-set 
				% 
				disp(['	Test set trimming: first LightsOff + ' num2str(trimming(1)), ' ms to ' num2str(trimming(2)), 'ms post lightsOff.'])
				obj.GLM.pos.testpos1 = obj.GLM.pos.lampOff(1)+trimming(1);
				obj.GLM.pos.testpos2 = obj.GLM.pos.lampOff(1)+trimming(2)-1;

				atest = obj.GLM.gfit_sm(obj.GLM.pos.testpos1:obj.GLM.pos.testpos2);
	            atest = atest';

				t_times = obj.GLM.gtimes(obj.GLM.pos.testpos1:obj.GLM.pos.testpos2);
				t = numel(atest);
				obj.GLM.flush.atest = atest;
				obj.GLM.flush.t_times_test = t_times;
				obj.GLM.flush.t_test = t;
			end
			% 
			% 	Generate the features
			% 
			[Xtest, xtest, ~] = obj.buildFeatures(xVS.th0_on, xVS.Events, xVS.x_style, t, t_times, xVS.x_bars, xVS.nobasisEvents, xVS.basisCurves, 'trial2lick');
			% 
			% 	Calculate the fit and statistics
			% 
			yFitTest = transpose(xVS.thFit) * Xtest;

			atest = a;
			disp('') 
			disp('============ RESULTS ============')
			obj.Stat.GLM.meanAtestLoss = 1/numel(atest)*sum((atest - mean(atest)).^2);
			obj.Stat.GLM.testSquaredLoss = 1/numel(atest)*sum((atest - yFitTest').^2);
			disp(['	Test Set Squared Loss of just using mean(atest) = ' num2str(obj.Stat.GLM.meanAtestLoss)])
			disp(['	Test Set Squared Loss of GLM fit = ' num2str(obj.Stat.GLM.testSquaredLoss)])

			obj.plotFit(yFitTest, atest, xtest, xVS.nobasisEvents);
			obj.findFeature(xVS.thFit, Xtest);
		end









		function [X, x, d] = buildFeatures(obj, th0_on, Events, x_style, t, t_times, x_bars, nobasisEvents, basisCurves, trimming)
			% 
			% 	Makes a feature representation array for input data
			% ----------------------------------------------------------------------------------- 
			
			if nargin < 10
				trimming = false;
			end
			% 
			% 	Construct the x-representations of events
			% 
			if strcmp(trimming, 'trial2lick')
				x = cellfun(@(event, x_style, eventNo) obj.makeXrepresentation(event, x_style, numel(obj.GLM.gtimes), obj.GLM.gtimes, eventNo), Events, x_style, num2cell(1:numel(Events)), 'UniformOutput', 0);
			else
				x = cellfun(@(event, x_style, eventNo) obj.makeXrepresentation(event, x_style, t, t_times, eventNo), Events, x_style, num2cell(1:numel(Events)), 'UniformOutput', 0);
			end
			% 
			% 	For each event's x-representation... Initialize the weights of the model from rand uniform dist
			% 
			for xEvent = 1:numel(x)
				% 
				% 	Get number of features (basis curves) for this event
				% 
				if strcmp(obj.Stat.GLM.eventNames{xEvent}, 'ssStretch')
					% 
					% 	There are two feature arrays in here, which we want to specify differently
					% 	start by extracting them -- I'll separate them
					% 	futher later
					% 
                    warning('start here to separate impulse from stretch in the eventMap')
					nth_impulse = numel(obj.GLM.flush.ssFeatureIdxs_impulse);
                    nth_dF2 = numel(obj.GLM.flush.ssFeatureIdxs_dF2);
                    nth{xEvent} = nth_impulse + nth_dF2;
					% 
					% 	Update the basis map
					% 
					mapIdx = obj.Stat.GLM.eventMap(xEvent);
					%  temp map goes from 2-end of event features, so here is #2-500
					tempMap = cell(nth{xEvent}-1, 2);
					for ifeat = 1:nth{xEvent}-1
						tempMap{ifeat, 1} = ['{1,' num2str(xEvent) '}{1, 1}{1,1}{1, 1}'];
						tempMap{ifeat, 2} = ['{1,' num2str(xEvent) '}{1, 1}{1,2}'];
					end
					% now insert tempMap into basisMap
					obj.Stat.GLM.basisMap = vertcat(obj.Stat.GLM.basisMap(1:mapIdx,1:2), tempMap, obj.Stat.GLM.basisMap(mapIdx+1:end,1:2));
				elseif strcmp(obj.Stat.GLM.eventNames{xEvent}, 'ramp-delta')
					warning('ramp-delta method is unnormalized veridical time!')
					% 
					% 	Here we must construct the design matrix for x. For now, just count the number of features we will need based on the max of the x-rep
					% 		Since there is one feature for each position of the ramp, the max is 7000 (since max ramp is 7000), though for some training sets this may be smaller...
					% 		will need to take care to throw a 7sec in there at some point...
                    %   Of course, the x rep has all the data, so we should
                    %   just cut it off at 7... - and I think we need to
                    %   downsample by 10 or this array is too big
					% 
                    xi = x{xEvent};
                    xi_sub7001 = xi(xi<7001);
					nth{xEvent} = ((6000*(max(xi_sub7001)>6000)) + max(xi_sub7001)*(max(xi_sub7001) < 6000))/10;
					pos = [1:10:(6000*(max(xi_sub7001)>6000)) + max(xi_sub7001)*(max(xi_sub7001) < 6000)];
					% warning('RBF 3-17-19')
					% 
					% 	Update the basis map
					% 
					mapIdx = obj.Stat.GLM.eventMap(xEvent);
					%  temp map goes from 2-end of event features, so here is #2-500
					tempMap = cell(nth{xEvent}-1, 2);
					for ifeat = 1:nth{xEvent}-1
						tempMap{ifeat, 1} = ['{1,' num2str(xEvent) '}{1, 1}{1,1}{1, 1}'];
						tempMap{ifeat, 2} = ['{1,' num2str(xEvent) '}{1, 1}{1,2}'];
					end
					% now insert tempMap into basisMap
					obj.Stat.GLM.basisMap = vertcat(obj.Stat.GLM.basisMap(1:mapIdx,1:2), tempMap, obj.Stat.GLM.basisMap(mapIdx+1:end,1:2));
					% warning('\RBF 3-17-19')
				elseif strcmp(obj.Stat.GLM.eventNames{xEvent}, 'ramp-delta-norm')
					warning('ramp-delta-norm method is veridical time!')
					% 
					% 	Here we must construct the design matrix for x. For now, just count the number of features we will need based on the max of the x-rep
					% 		Since there is one feature for each position of the ramp, the max is 7000 (since max ramp is 7000), though for some training sets this may be smaller...
					% 		will need to take care to throw a 7sec in there at some point...
                    %   Of course, the x rep has all the data, so we should
                    %   just cut it off at 7... - and I think we need to
                    %   downsample by 10 or this array is too big
					% 
                    if isfield(obj.GLM.flush, 'SnTrialsUniform')
    					pos = 1:10:(max(obj.GLM.flush.samples_bt_c2l(obj.GLM.flush.SnTrialsUniform)));
                    else
                        pos = 1:10:(max(obj.GLM.flush.samples_bt_c2l(obj.GLM.flush.SnTrials_sub7)));
                    end
					nth{xEvent} = numel(pos);
					% warning('RBF 3-17-19')
					% 
					% 	Update the basis map - note must also remove unused th, see below 
					% 
					mapIdx = obj.Stat.GLM.eventMap(xEvent);
					%  temp map goes from 2-end of event features, so here is #2-500
					tempMap = cell(nth{xEvent}-1, 2);
					for ifeat = 1:nth{xEvent}-1
						tempMap{ifeat, 1} = ['{1,' num2str(xEvent) '}{1, 1}{1,1}{1, 1}'];
						tempMap{ifeat, 2} = ['{1,' num2str(xEvent) '}{1, 1}{1,2}'];
					end
					% now insert tempMap into basisMap
					obj.Stat.GLM.basisMap = vertcat(obj.Stat.GLM.basisMap(1:mapIdx,1:2), tempMap, obj.Stat.GLM.basisMap(mapIdx+1:end,1:2));
					% warning('\RBF 3-17-19')
				elseif strcmp(obj.Stat.GLM.eventNames{xEvent}, 'stretch-time')
					% warning('stretch-time method recently implemented, debug here!')
					% 
					% 	Written to do 0.2% per feature for now
					% 
					nth{xEvent} = 500;
					% warning('RBF 3-17-19')
					% 
					% 	Update the basis map
					% 
					mapIdx = obj.Stat.GLM.eventMap(xEvent);
					%  temp map goes from 2-end of event features, so here is #2-500
					tempMap = cell(nth{xEvent}-1, 2);
					for ifeat = 1:nth{xEvent}-1
						tempMap{ifeat, 1} = ['{1,' num2str(xEvent) '}{1, 1}{1,1}{1, 1}'];
						tempMap{ifeat, 2} = ['{1,' num2str(xEvent) '}{1, 1}{1,2}'];
					end
					% now insert tempMap into basisMap
					obj.Stat.GLM.basisMap = vertcat(obj.Stat.GLM.basisMap(1:mapIdx,1:2), tempMap, obj.Stat.GLM.basisMap(mapIdx+1:end,1:2));
					% warning('\RBF 3-17-19')
                elseif numel(x_bars{1,xEvent}) ~= 1
                    nth{xEvent} = sum(cellfun(@(x) numel(x), x_bars{1,xEvent}));
                else
                    nth{xEvent} = 1;
                end
				% 
				% 	Initialize theta (coefficient vector of weights)
				% 
				th_x{xEvent} = obj.initTheta(nth{xEvent}, [-1,1]);
			end
			% 
			% 	Generate the theta vector for whole dataset:
			% 		th = (d x 1) vector of weights for each feature. If there's a th0, add another rand on the bottom
			% 
			th = cell2mat(reshape(th_x,[],1));
			d = numel(th);
			% 
			% 	Handle case for th0 offset
			% 
			if th0_on
				th(end+1) = rand;
				% 
				% 	Range is (-1,1) for th0, not including 0
				% 
				if rand < 0.5
					th(end) = -th(end);
				end
				d = d+1;
			end
			% th_init = th;

% 
            % 	Do a quick memory check before proceeding
            % 
            % maxMemFrac = 0.4; %# I want to use at most 95% of the available memory. 
            % I assume at baseline we are using about 55% of memory
            % and we will need to make at least 2x the size of X to do the fit, so 95-55 = 40, thus 20% for the X array

			numElements = 2*d*t;
			numBytesNeeded = numElements * 8; %# I use double

			%# read available memory
			[~,memStats] = memory;

			if numBytesNeeded > memStats.PhysicalMemory.Available
			   warning('Creating X and X'' arrays will use at least 100% remaining memory. Ok to proceed? If not, make space')
			   warning(['numBytesNeeded = ' num2str(numBytesNeeded) ' of ' num2str(memStats.PhysicalMemory.Available) ' available (' num2str(100*numBytesNeeded/memStats.PhysicalMemory.Available) ') - can go up to 111% with 25% used without problems']);
               close all
			end

			% 
			%	Create the feature matrix, X
			% 
			% 	X = (d x t) -- d features (vertcat the bases and add a theta zero), t timepoints (aka n)
			%		If th0 is in use, add a feature of all 1's in row d 
			% 
			disp(' ')
			disp(['		Creating feature representations = X... ', datestr(now)])
			X = nan(d, t);
            d_idx = 1;
			for xEvent = 1:numel(x)
                if ~ismember(xEvent, nobasisEvents)%%~strcmp(obj.Stat.GLM.eventNames{xEvent}, 'EMG') && ~strcmp(obj.Stat.GLM.eventNames{xEvent}, 'timing')%
    				for curve = 1:numel(basisCurves{1, xEvent})  
                        disp(['         Event #', num2str(xEvent), ' Curve #' num2str(curve), '...' datestr(now)])
                        xCb = arrayfun(@(xshift) obj.convX_basisCos(x{xEvent}, basisCurves{1,xEvent}{1,curve}, xshift, xEvent), x_bars{1, xEvent}{1, curve}, 'UniformOutput', 0);
                        % 
                        % 	If we only want to consider points within a spliced window, cut out anything that is out of the window now
                        % 
                        if strcmp(trimming, 'trial2lick')
                        	xCb = cellfun(@(x) x(obj.GLM.flush.idxcat), xCb, 'UniformOutput', 0);
                    	end
                        xCb_stack = reshape(xCb, [], 1);
                        X(d_idx:d_idx-1+numel(xCb_stack), :) = cell2mat(xCb_stack);
                        d_idx = d_idx+numel(xCb_stack);
                    end
%                 elseif strcmp(obj.Stat.GLM.eventNames{xEvent}, 'EMG')
%                 	error('NOT IMPLEMENTED!')
%                 	% 
                	% 	Need to make a convolve method for gaussian kernel... and validate. Do this next.
                	% 
                	% xCb = arrayfun(@(xshift) obj.convX_basisCos(x{xEvent}, basisCurves{1,xEvent}{1,curve}, xshift), x_bars{1, xEvent}{1, curve}, 'UniformOutput', 0);
                	% c = conv(shiftx, basis_y, 'same');
                else    % if this is a timing event with no basis convolution...
                	if strcmp(obj.Stat.GLM.eventNames{xEvent}, 'ramp-delta')
						% warning('ramp-delta method recently implemented, debug here! - note, only made for trial2lick for now')
						X(d_idx:d_idx+nth{xEvent}-1, :) = obj.oneHotDesignMatrix(x{xEvent}(obj.GLM.flush.idxcat), pos);
						d_idx = d_idx+nth{xEvent};
					elseif strcmp(obj.Stat.GLM.eventNames{xEvent}, 'ramp-delta-norm')
						warning('ramp-delta-norm method INCOMPLETELY DEBUGGED, debug here! - note, only made for trial2lick for now')
						[X(d_idx:d_idx+nth{xEvent}-1, :), th2remove] = obj.scaledHeatDesignMatrix(x{xEvent}(obj.GLM.flush.idxcat), pos);
						d_idx = d_idx+nth{xEvent};
						% 
						% 	Check and be sure that the features all exist, otherwise won't fit
						%
						if ~isempty(th2remove)
							warning(['These ramp-delta-norm features are empty: ', num2str(th2remove), ' out of nth{xEvent}'])
							% 
							% 	Trim out the unwanted feature
							% 
							X = X(1:end-numel(th2remove), :);
							d = d - numel(th2remove);
							nth{xEvent} = nth{xEvent} - numel(th2remove);
							d_idx = d_idx - numel(th2remove);
						end
						% 
						% 	Trim the basis-map
						% 
						obj.Stat.GLM.basisMap = vertcat(obj.Stat.GLM.basisMap(1:mapIdx-1,1:2), obj.Stat.GLM.basisMap(mapIdx+numel(th2remove):end,1:2));
					elseif strcmp(obj.Stat.GLM.eventNames{xEvent}, 'stretch-time')
						[X(d_idx:d_idx+nth{xEvent}-1, :)] = obj.stretchedTimeDesignMatrix(x{xEvent}(obj.GLM.flush.idxcat));
						d_idx = d_idx+nth{xEvent};
					elseif strcmp(obj.Stat.GLM.eventNames{xEvent}, 'ssStretch')
						warning('ssStretch-time method recently implemented, debug here!')
                        xCb = [vertcat(x{xEvent}{:,1}); vertcat(x{xEvent}{:,2})];
                        if strcmp(trimming, 'trial2lick')
                        	xCb = xCb(:, obj.GLM.flush.idxcat);
                    	end
						[X(d_idx:d_idx+nth{xEvent}-1, :)] = xCb;
						d_idx = d_idx+nth{xEvent};	
					else
	                    if strcmp(trimming, 'trial2lick')
	                		X(d_idx, :) = x{xEvent}(obj.GLM.flush.idxcat);
	                        d_idx = d_idx+1;
	                	else
	                        X(d_idx, :) = x{xEvent};
	                        d_idx = d_idx+1;
	                    end
                    end
				end
			end
			if th0_on
				X(d, :) = ones(1, t);
			end
			% 
			% 	Try making matrix sparce to save memory if more than 66% empty
			% 
			if sum(X>0)/numel(X) > 0.66
				disp('		Using sparce X representation...')
				X = sparse(X);
			end
			obj.GLM.flush.nth = nth;
		end



	
		


		function [th, yFit] = ridge(obj, X, a, x, nobasisEvents, verbose, lam, th)
            disp('========= GRADIENT DESCENT RIDGE REGRESSION =========')
            if nargin < 6
                verbose = true;
            end
            if nargin < 7
                lam = 0;%.0001;
            end
            disp(['		Model lambda = ', num2str(lam)])
            if nargin < 8
            	thwt = 0.001;
            	if verbose, disp(['      Generating random th_init based on range of actual data, weight = ', num2str(thwt)]), end
			% th = obj.initTheta(size(X,1), [0.01*min(a),0.01*max(a)]);
                th = obj.initTheta(size(X,1), [-thwt*max(a),thwt*max(a)]);
            end
            % 
            % 	Calculate chance model loss for this set:
            % 
            meanAloss = 1/numel(a)*sum((a - mean(a)).^2);
            disp(['     Mean loss from actual data: ', num2str(meanAloss)])

			niter = 1000;
            del_stop = 0.0000001;
            Loss_explode = 0.01;
            
            if size(a,2) ~= size(th'*X, 2)
                a = a';
            end

            % G = zeros(size(th));
            
			for iter = 1:niter
				eta = 1;
				% 
				% 	Calculate the loss
				% 
				L(iter) = 1/numel(a)*(a - th'*X)*(a - th'*X)'/2 + lam/2 * norm(th)^2;
				% 
				% 	Calculate the gradient
				% 
				d_th = 1/numel(a)*((a - th'*X) * -X')' + lam * norm(th);
				% 
				% 	Calculate adagrad
				% % 
				% G = G + d_th^2;
				% ada = eta/
				% 
				% 	Step it down that gradient...
				% 
				th = th - (eta)*d_th;
				% th = th - (eta/G^.5)*d_th;
				% 
                if numel(L)>1
                    d = L(iter) - L(iter-1);
                    if abs(d) <= del_stop
                        if verbose
                            disp('Reached stopping del. Ending iteration...')
                        end
                        break
                    elseif d >= Loss_explode
                    	if verbose
                            disp('Lambda has generated exploding loss. Stopping...')
                        end
                        break
                    elseif ~rem(iter,5) && verbose
                        disp(['     iter: ' num2str(iter), ' Loss = ' num2str(L(iter)), ' del = ' num2str(d)])
                    end
                end
			end
			% 
			% 	Plot the Loss vs iter
			% 
			yFit = obj.calcYfit(th, X);
			figure, 
            % subplot(1,3,1)
            plot(L, '-ro');
			title('Loss vs Iteration')
			xlabel('Iteration #')
			ylabel('Loss')
   %          subplot(1,3,2)
   %          plot(th, '-bo');
			% title('th')
			% xlabel('feature #')
			% ylabel('value')
			% subplot(1,3,3)
			% hold on
			% plot(a, 'r-', 'LineWidth', 6, 'DisplayName', 'Actual');
			% plot(yFit, 'b-', 'LineWidth', 3, 'DisplayName', 'Fit');
			% title('Fit vs Actual')
			% legend('show')
			obj.plotFit(yFit, a, x, nobasisEvents);
			obj.findFeature(th, X);
            disp(['     Squared loss of model: ', num2str(L(end))])
		end







		function thXsingle = totalFeatureForEvent(obj, th, eventNo, bC, xb, n, ax)
			% 
			% 	Calculate the overall feature representation for each event
			% 
			%  Use this offline: else
			%	 bC = xValidationStruct.basisCurves;
			%    xb = xValidationStruct.x_bars
			% ---------------------------------------------------
			% 
			% 	Get indicies of features for this event
			% 
			featIdxs = obj.Stat.GLM.eventMap(eventNo):obj.Stat.GLM.eventMap(eventNo+1)-1;
			th_matched = th(featIdxs);
			if ~strcmp(obj.Stat.GLM.eventNames{eventNo}, 'timing-ramp-conv')
				thXsingle = th_matched'*obj.Stat.GLM.basisXsingles{1, eventNo};
            else
                if nargin < 7
                    figure
                    ax = axes;
                end
                if nargin < 6
                    n = 7000;
                end
% 				if exist('basisCurves')
% 					bC = basisCurves;
% 					xb = x_bars;
%                 end
                thIdx = 1;
                thX = {};
				for curve = 1:numel(bC{1, eventNo}) 
					x = [1:n]./n;
					% 
					% 	Must convolve the feature since these aren't deltas
					% 
					xCb = arrayfun(@(xshift) obj.convX_basisCos(x, bC{1,eventNo}{1,curve}, xshift, eventNo), xb{1, eventNo}{1, curve}, 'UniformOutput', 0);
	                % 
	                xCb_stack = reshape(xCb, [], 1);
                    thX{curve, 1} = th_matched(thIdx:thIdx+size(xCb_stack)-1)'*cell2mat(xCb_stack);
                    thIdx = thIdx+size(xCb_stack);
                end
                thXsingle = sum(cell2mat(thX),1);
                plot(ax, thXsingle);
			end
		end


		function findFeature(obj, th, X)
			% 
			% 	This will plot the coefficients and allow you to click on each one. Then it will plot the corresponding feature
			% ------------------------------------------------- 
			% 
			% 	Plot th weights
			% 
			f = figure;
            WinOnTop(f);
			ax(1) = subplot(1,2,1);
			xlabel('Feature #')
			ylabel('Weight Value')
			title('Fit Feature Weights')
			hold on
			if isfield(obj.Stat.GLM, 'se_th')
				% stem(1:numel(obj.Stat.GLM.se_th), th - obj.Stat.GLM.se_th, 'k.-', 'HandleVisibility','off')
				% stem(1:numel(obj.Stat.GLM.se_th), th + obj.Stat.GLM.se_th, 'k.-', 'HandleVisibility','off')
				stem(find(obj.Stat.GLM.signifCoeff>0), max(th).*ones(size(find(obj.Stat.GLM.signifCoeff>0))), 'y*', 'HandleVisibility','off')
				plot(1:numel(obj.Stat.GLM.se_th), th - obj.Stat.GLM.se_th, 'k.-', 'HandleVisibility','off')
				plot(1:numel(obj.Stat.GLM.se_th), th + obj.Stat.GLM.se_th, 'k.-', 'HandleVisibility','off')
			end
			lh(1) = plot([0,numel(th)], [0,0], 'k-', 'DisplayName', 'meridian');
			colorMap = {'-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo','-ro', '-go', '-bo', '-co', '-mo'};
			if obj.Stat.GLM.eventMap(end) < numel(th)-1
				obj.Stat.GLM.eventMap(end+1) = numel(th);
			end
			for iEvent = 1:numel(obj.Stat.GLM.eventMap)-1
				lh(iEvent+1) = plot(ax(1), obj.Stat.GLM.eventMap(iEvent):obj.Stat.GLM.eventMap(iEvent+1), th(obj.Stat.GLM.eventMap(iEvent):obj.Stat.GLM.eventMap(iEvent+1)), colorMap{iEvent}, 'MarkerSize', 3, 'DisplayName', obj.Stat.GLM.eventNames{iEvent});
                set(lh(end),'hittest','off'); % so you can click on the Markers
			end
			lh(iEvent+1) = plot(numel(th),th(end), 'k*', 'MarkerSize', 12, 'DisplayName', 'theta0');
			set(lh(end),'hittest','off'); % so you can click on the Markers
			legend('show')
			ylim([min(th)-0.05*max(abs(th)), max(th)+0.05*max(abs(th))])


			ax(2) = subplot(3,2,2);
			title('Feature Shape')
			xlabel('time with respect to event (ms)')
			ylabel('normalized feature amplitude')


			ax(3) = subplot(3,2,4);
			title('Feature * Event')
			xlabel('time in fit window (s)')

			ax(4) = subplot(3,2,6);
			title('Event Representation')
			xlabel('time relative to event (ms)')

			set(ax(1),'ButtonDownFcn',@(src, event)obj.plotFeature(ax(1), 'ButtonDownFcn', ax, th, X)); % Defining what happens when clicking


		end 

		function plotFeature(obj, src, event, ax, th, X)
% 			disp('in PlotFeature')
			cla(ax(2),'reset')
			cla(ax(3),'reset')
			cla(ax(4),'reset')
			f = ancestor(ax(1),'figure');
			click_type = get(f,'SelectionType');
			ptH = getappdata(ax(1),'CurrentPoint');
			delete(ptH)
		    %Finding the closest point and highlighting it
		    lH = findobj(ax(1),'Type','line');
		    minDist = realmax;
		    finalIdx = NaN;
		    finalH = NaN;
		    pt = get(ax(1),'CurrentPoint'); %Getting click position
		    for ii = lH'
		        xp=get(ii,'Xdata'); %Getting coordinates of line object
		        yp=get(ii,'Ydata');
		        dx=daspect(ax(1));      %Aspect ratio is needed to compensate for uneven axis when calculating the distance
		        [newDist idx] = min( ((pt(1,1)-xp).*dx(2)).^2 + ((pt(1,2)-yp).*dx(1)).^2 );
		        if (newDist < minDist)
		            finalH = ii;
		            finalIdx = idx;
		            minDist = newDist;
		        end
		    end
		    xp=get(finalH,'Xdata'); %Getting coordinates of line object
		    yp=get(finalH,'Ydata');
		    ptH = plot(ax(1),xp(finalIdx),yp(finalIdx),'ro','MarkerSize',15, 'DisplayName', 'PROCESSING SELECTION...');
		    setappdata(ax(1),'CurrentPoint',ptH);
		    legend(ax(1), 'show')
		    drawnow
		    % 
		    % 	Now plot in the second set of axes the features
		    % 
		    yl = ylim(ax(1));
		    feature_number = xp(finalIdx);
		    if feature_number == numel(th)
		    	% event_number = str2num('th0 Offset');
		    	plot(ax(2), [0,10], [th(feature_number),th(feature_number)], 'k-', 'DisplayName', 'th0 offset term');
		    	ylim([min(th),max(th)]);
	            legend(ax(2), 'show')
				title(ax(2), 'Feature Shape')
				% xlabel(ax(2), 'time with respect to event (s)')
				ylabel(ax(2), 'normalized feature amplitude')
				ylim(ax(2), yl);
	    	else
			    event_delimiter = obj.Stat.GLM.basisMap{feature_number, 2};
	            event_number_pos1 = strfind(event_delimiter, ',');
	            event_number_pos1 = event_number_pos1(1)+1;
	            event_number_pos2 = strfind(event_delimiter, '}');
	            event_number_pos2 = event_number_pos2(1)-1;
	            event_number = str2num(event_delimiter(event_number_pos1:event_number_pos2));

	            colorMap = {'-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m','-r', '-g', '-b', '-c', '-m'};
			    hold(ax(2), 'on');
			    eval(['plot(ax(2), [(min(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} '/1000) < 0)*min(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} '/1000), (max(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} ')/1000>0)*max(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} '/1000)], [0,0], ''k-'', ''DisplayName'', ''meridian'')'])
			    eval(['plot(ax(2), obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1}, '/1000, th(', num2str(feature_number), ').*obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 2} ', ''' colorMap{event_number} ''', ''DisplayName'', ['' Event #'' num2str(event_number), '' -- Feature #'', num2str(feature_number)])'])
	            legend(ax(2), 'show')
			    eval(['set(ax(2), ''xlim'', [(min(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} '/1000) < 0)*min(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} '/1000), (max(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} '/1000)>0)*max(obj.Stat.GLM.basisSet' obj.Stat.GLM.basisMap{feature_number, 1} '/1000)])'])
				title(ax(2), 'Feature Shape')
				xlabel(ax(2), 'time with respect to event (s)')
				ylabel(ax(2), 'normalized feature amplitude')
				ylim(ax(2), yl);
			end
		    % 
		    % 	Now plot the feature representation in the third set of axes
		    % 
		    % gca = ax(3);
		    if feature_number == numel(th)
		    	plot(ax(3), (1:size(X,2))/1000, th(feature_number).*X(feature_number, :), 'k-')
	    	else
	    		plot(ax(3), [0,size(X, 2)]/1000, [0,0], 'k-', 'DisplayName', 'th0 offset term');
			    hold(ax(3), 'on')
			    plot(ax(3), [1:size(X,2)]/1000, th(feature_number).*X(feature_number, :), colorMap{event_number})
		    end
			title(ax(3), 'Feature * Event')
			xlabel(ax(3), 'time in fit window (s)')
			ylim(ax(3), yl);
			% 
			% 	Now plot the total representation for this event!
			% 
			if feature_number == numel(th)
				plot(ax(4), th(feature_number).*X(feature_number, :), 'k-')
				title(ax(4), 'th0 Offset')
				xlabel(ax(4), '')
				ylim(ax(4), yl);
	    	else
	    		plot(ax(4), [obj.Stat.GLM.basisXaxes{event_number}(1)/1000, obj.Stat.GLM.basisXaxes{event_number}(end)/1000], [0,0], '-k', 'DisplayName', 'meridian'); 
				hold(ax(4), 'on');
				temp = obj.Stat.GLM.totalFeatureForEvent{event_number}'; %'
                if numel(obj.Stat.GLM.basisXaxes{event_number}) == numel(temp)
    				eval(['plot(ax(4), obj.Stat.GLM.basisXaxes{event_number}./1000, temp,''' colorMap{event_number} ''', ''DisplayName'', [''Event #'', num2str(event_number)]);']) 
                    xlabel(ax(4), 'Time relative to event (s)')
                    ylim(ax(4), [min(temp)*(min(temp) < 0), max(temp)*(max(temp) > 0)])					            
                elseif isfield(obj.GLM.flush, 'idxcat') && ~strcmp(obj.Stat.GLM.eventNames{event_number}, 'cue') && ~strcmp(obj.Stat.GLM.eventNames{event_number}, 'lick') && ~strcmp(obj.Stat.GLM.eventNames{event_number}, 'timing-ramp-conv')
                    eval(['plot(ax(4), X(feature_number, :),''' colorMap{event_number} ''', ''DisplayName'', [''Event #'', num2str(event_number)]);']) 
                else
                    eval(['plot(ax(4), (1:numel(temp))./1000, temp,''' colorMap{event_number} ''', ''DisplayName'', [''Event #'', num2str(event_number)]);']) 
                    xlabel(ax(4), 'Event representation over fit interval (s)')
                    ylim(ax(4), [min(temp)*(min(temp) < 0), max(temp)*(max(temp) > 0)])					            
                end
				legend(ax(4), 'show')
				title(ax(4), ['Event #', num2str(event_number), ' Kernel'])
				
				ylabel(ax(4), 'Feature amplitude')
				
			end			

			% 
			% 	Indicate plots done
			% 
			ptH = getappdata(ax(1),'CurrentPoint');
			delete(ptH)
			ptH = plot(ax(1),xp(finalIdx),yp(finalIdx),'ko','MarkerSize',10, 'DisplayName', 'Current Selected Feature');
		    setappdata(ax(1),'CurrentPoint',ptH);
		    drawnow

		end






		function yFit = calcYfit(obj, th, X)
			% 
			% 	Returns the actual yFit so that you can plot it and stuff
			% 
			yFit = th.'*X;
		end 

		function ax = plotFit(obj, yFit, a, x_events, no_dot_events)
			% 
			% 	Plots yFit and actual y = "a" for comparison
			% 
			if nargin < 5
				no_dot_events = [];
			end

			figure,
			ax(1) = subplot(4,1,1);
			plot(a)
			title('a = actual data')

			ax(2) = subplot(4,1,2);
			plot(yFit)
			title('yFit')

			ax(3) = subplot(4,1,3);
			hold on
			plot(a, 'LineWidth', 3, 'DisplayName', 'Actual')
			plot(yFit, 'LineWidth', 1, 'DisplayName', 'yFit')
			title('Overlay')
			legend('show')

			ax(4) = subplot(4,1,4);
			hold on
			% for ievent = 1:numel(x_events)
   %              xpos = find(x_events{ievent} > 0);
			% 	plot(xpos,ievent*ones(numel(xpos)), 'o', 'DisplayName', ['Event #', num2str(ievent)]);
   %          end
   			for ievent = 1:numel(x_events)
   				if ismember(ievent, no_dot_events)
   					if isfield(obj.GLM.flush, 'idxcat')
	   					plot(x_events{ievent}(obj.GLM.flush.idxcat)+ievent, '-', 'DisplayName', ['Event #', num2str(ievent)]);
   					else
   						plot(x_events{ievent}+ievent, '-', 'DisplayName', ['Event #', num2str(ievent)]);
					end
				else
					if isfield(obj.GLM.flush, 'idxcat')	
%                         warning('THERE''S A PROBLEM WITH INDEXING OF CUE AND LICK EVENTS, START HERE')
                        xpos = find(x_events{ievent}(obj.GLM.flush.idxcat) > 0);
						if strcmp(obj.Stat.GLM.eventNames{ievent}, 'flick')
% 							warning('I''m not sure this plot of the flick event is correct, since idx is wrt all trials...')
% 							plot(xpos(obj.GLM.flush.SnfLickIdx),ievent*ones(numel(xpos)), 'o', 'DisplayName', ['Event #', num2str(ievent)]);
                            plot(xpos,ievent*ones(1,numel(xpos)), 'o', 'DisplayName', ['Event #', num2str(ievent)]);
                        else
                            epos = find(x_events{ievent} > 0);
							plot(xpos,ievent*ones(1,numel(xpos)), 'o', 'DisplayName', ['Event #', num2str(ievent)]);
%                             plot(xpos,ievent*ones(numel(xpos)), 'o', 'DisplayName', ['Event #', num2str(ievent)]);
						end

					else
		                xpos = find(x_events{ievent} > 0);
						plot(xpos,ievent*ones(1, numel(xpos)), 'o', 'DisplayName', ['Event #', num2str(ievent)]);
					end
				end
            end
            
            linkaxes(ax, 'x')
		end 


		function ax = plotFeatureSpace(obj, X)
			figure, 
			ax = gca;
			hold on
			for iplot = 1:size(X,1), plot(X(iplot, :)), end
		end

		function th = initTheta(obj, nth, Range)
			% 
			% 	Randomize coefficients for beginning of GD
			% 		th = [n x 1] vector of coefficient weights
			% 	
			if nargin < 3
				Range = [0, 1];
			end
			th = rand(nth, 1);
            mask = rand(nth, 1);
			if Range(1) == -1
				th(mask<0.5) = -th(mask<0.5);
			end
			if Range(1) ~= -1 && Range(1) < 0
				th(mask<0.5) = Range(1)*th(mask<0.5);
			end
			if Range(2) > 0 && Range(2) ~=1
				th(mask>=0.5) = Range(2)*th(mask>=0.5);
			end
		end


		function c = convX_basisCos(obj, X, basis_y, x_bar, eventNo)
			% 
			% 	We will shift around the X representation to get x_bar timeshifts in the convolution
			%--------------------------------------------------

			%
			%	For each x_bar, we need to shift around the X-representation to do the convolution. 
			% 
			% 	negative xbar: X(first event timestamp-1/2width-abs(xbar):end)
			% 	zero xbar: X(first event timestamp-1/2width:end)
			% 	positive xbar: X(first event timestamp-1/2width+abs(xbar):end)
			% 
            x_bar = round(x_bar);
            pad = 20000;
			firstevent = find(X>0, 1, 'first');
			Width = numel(basis_y);
			halfwidth = Width/2;
            padX = horzcat(zeros(1, pad), X);
            % 
            % 	Shift all the x_bars by the half-width to ensure correct spacing
            % 
            x_bar = x_bar + halfwidth;
            
            

			if x_bar == 0
				% Sits flush with delta
                shiftx = padX;
				c = conv(shiftx, basis_y, 'same');
                c = c(pad+1:end);
                
				%                 figure,
				%                 hold on
				%                 plot(X, 'DisplayName', 'X')
				%                 plot(shiftx, 'DisplayName', 'shiftx')
				%                 plot(basis_y, 'DisplayName', 'basis_y')
				%                 plot(c, 'DisplayName', 'c')
				%                 legend('show')
            elseif x_bar < 0
                % Sits left of the delta
                % We gotta pad the X in case of it hanging off the side  
                shiftx = padX(-round(x_bar):end);
				c = conv(shiftx, basis_y, 'same');
                c = horzcat(c, zeros(1, -round(x_bar)-1));
                c = c(pad+1:end);
                
				%                 figure,
				%                 hold on
				%                 plot(X, 'DisplayName', 'X')
				%                 plot(shiftx, 'DisplayName', 'shiftx')
				%                 plot(basis_y, 'DisplayName', 'basis_y')
				%                 plot(c, 'DisplayName', 'c')
				%                 legend('show')
            elseif x_bar > 0
                % Sits right of the delta
				shiftx = horzcat(zeros(1, round(x_bar)), padX);
				c = conv(shiftx, basis_y, 'same');
                c = c(1, 1:end-round(x_bar));
                c = c(pad+1:end);
            end		

%             if strcmp(obj.Stat.GLM.eventNames{eventNo}, 'timing-ramp-conv')				% 
% 	            % 	If this event is a ramp-conv, we need to mask it with zeros...
% 	            % 
%             	% zeroMask = X == 0;
%             	% c = c .* zeroMask;
%             	% 
%             	% 
%             	% 
%                 figure,
%                 hold on
%                 plot(X, 'DisplayName', 'X')
%                 plot(shiftx, 'DisplayName', 'shiftx')
%                 plot(basis_y, 'DisplayName', 'basis_y')
%                 plot(c, 'DisplayName', 'c')
%                 legend('show')
%             	warning('THIS DOESN''T WORK - don''t use timing-ramp-conv because ramps will overlap onto other trials...')
%         	end
            %
            %   DEBUG
            %
            % plot(c(8000000:end))
		end


		function ax = plotBasis(obj, basis)
			figure;
			ax =subplot(1,1,1);
			hold on
			for iset = 1:length(basis)
				cellfun(@(x) plot(ax, x,basis{1,iset}{1,2}), basis{1, iset}{1, 1})
			end
		end



		function [basisXaxis, basisXsingle] = alignFeatures(obj, basisSet, basisMap)
			% 
			% 	Takes the basisSet and eventNo and makes an array of aligned features for plotting, etc
			% 
			% ----------------------------------------------------
			% 
			% 	Align all the features:
			% 
			% 		Find the minimum x position and the maximum x position
			% 
			xMin = 0;
			xMax = 0;
            startidx = strfind(basisMap{1,1},'{');
            for feat = 1:size(basisMap,1)
    			eval(['xMin = min(min(basisSet' basisMap{feat , 1}(startidx(2):end)  '), xMin);'])
    			eval(['xMax = max(max(basisSet' basisMap{feat , 1}(startidx(2):end)  '), xMax);'])
            end
            basisXaxis = xMin:xMax;
            basisXsingle = zeros(size(basisMap,1), length(basisXaxis));
            % 
            % 		Make aligned arrays for each
            % 
            for feat = 1:size(basisMap,1)
    			eval(['xPositions = find(basisXaxis >= basisSet ' basisMap{feat , 1}(startidx(2):end)  '(1), 1, ''first'');'])
    			eval(['xPositions = xPositions:xPositions+numel(basisSet ' basisMap{feat , 1}(startidx(2):end)  ') - 1;'])
    			eval(['basisXsingle(feat, xPositions) = basisSet ' basisMap{feat , 2}(startidx(2):end) ';']);
            end
		end


		function [basis, x_bars, basisMap, basisXaxis, basisXsingle] = makeBasis(obj, Mode, nBasis, centering, width, spacing)
		% 
		% 	Use this function to generate basis sets for constructing the GLM model
		% 		Note that time-shifts will be applied to the behavioral events, NOT to the basis - that won't allow us to to non-causal filtering
		% 
		% 	basis: 	{ { {short xs}, [short ys]}, { {mid xs}, [mid ys]}, ... , { {long xs}, [long ys]} } -- use for plotting
		% 
		% 	nBasis: this is the index for the event for which we are making this basis set. This is needed for recalling and mapping features after processing
		% 
			if nargin < 3
				% 
				% 	If the number of this basis in the set isn't specified, set it to 1
				% 
				nBasis = 1;
			end
		% 
			run_style = '';

			if strcmpi(Mode, 'cue')
				run_style = '2';
				% 
				% 	The mode is gauss, centering is causal (so right shift all)
				% 
				% 	The offsets from the behavioral event: (overlap is b-width (stride is 1/2))
				% 
				 % 
				if strcmp(run_style, 'full')
					% 
					% 	Widths (ms):
					%
					ws = [50, 100, 500, 1000, 5000];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'causal');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 1000, 'causal');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'causal');
	                x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 7000, 'causal');
	                x_bars{5} = obj.tileSpace(ws(5), ws(5)/2, 14000, 'causal');
				elseif strcmp(run_style, '3')
					ws = [50, 100, 200];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/4, 500, 'causal');
                	x_bars{2} = obj.tileSpace(ws(2), ws(2)/4, 500, 'causal');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/4, 500, 'causal');
					% ws = [100, 500, 1000];
					% x_bars = cell(1, numel(ws));
					% x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 1000, 'causal');
	    %             x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 5000, 'causal');
	    %             x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 5000, 'causal');
				elseif strcmp(run_style, '2')
					ws = [100, 200];
					x_bars = cell(1, numel(ws));
					x_bars{1} = obj.tileSpace(ws(1), ws(1)/4, 500, 'causal');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/4, 500, 'causal');
                elseif strcmp(run_style, '1')
                	ws = [100];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'causal');
				end	
				% 
				% 	Generate the basis set
				% 
				basis = cellfun(@(w, x_bar) obj.makeHalfCosVect(w, x_bar), num2cell(ws), x_bars, 'UniformOutput', 0);
				% 
				%	Generate the basis Map - this will let us easily jump to any of the features 
				% 
				basisMap = cell(sum(cellfun(@(x) numel(x), basis)),2);
				mapidx = 1;
				for iWs = 1:numel(ws)
					for xbar = 1:numel(x_bars{iWs})
 						basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
 						basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
						mapidx = mapidx + 1;
					end
				end
				% 
				% 	Align the features into the basisXsingle array
				% 
				[basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);


			elseif strcmpi(Mode, 'lick')
				run_style = '2';
				% 
				% 	The offsets from the behavioral event: (overlap is b-width (stride is 1/2))
				% 
				 % 
				if strcmp(run_style, 'full')
					% 
					% 	Widths (ms):
					%
					ws = [50, 100, 500, 1000, 5000];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'center');
                	x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 1000, 'center');
                	x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'center');
                	x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 7000, 'center');
                	x_bars{5} = obj.tileSpace(ws(5), ws(5)/2, 14000, 'center');
	                % x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'left');
	                % x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 1000, 'left');
	                % x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'left');
	                % x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 7000, 'left');
	                % x_bars{5} = obj.tileSpace(ws(5), ws(5)/2, 14000, 'left');
				elseif strcmp(run_style, '3')
					% ws = [50, 100, 500, 1000];
					% ws = [500, 1000];
					% ws = [100, 500, 1000];
					ws = [50, 100, 200];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/4, 500, 'left');
                	x_bars{2} = obj.tileSpace(ws(2), ws(2)/4, 500, 'left');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/4, 500, 'left');
					% x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 1000, 'left');
	    %             x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 5000, 'left');
	    %             x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 8400, 'left');
				elseif strcmp(run_style, '2')
					ws = [100, 200];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/4, 500, 'left');
                	x_bars{2} = obj.tileSpace(ws(2), ws(2)/4, 500, 'left');
				elseif strcmp(run_style, '1')
                	ws = [100];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'left');
				end	
				% 
				% 	Generate the basis set
				% 
				basis = cellfun(@(w, x_bar) obj.makeHalfCosVect(w, x_bar), num2cell(ws), x_bars, 'UniformOutput', 0);
				% 
				%	Generate the basis Map - this will let us easily jump to any of the features 
				% 
				basisMap = cell(sum(cellfun(@(x) numel(x), basis)),1);
				mapidx = 1;
				for iWs = 1:numel(ws)
					for xbar = 1:numel(x_bars{iWs})
 						basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
 						basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
						mapidx = mapidx + 1;
					end
                end
                % 
				% 	Align the features into the basisXsingle array
				% 
				[basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);
                
			elseif strcmpi(Mode, 'timing')
				% 	
				% 	Update: 3/17/19: we want to distinguish other x-styles using this from the ramp-untrimmed x-stle
				% 			If the style is ramp-untrimmed, we want to make a basis map that will include all these points
				% 			It may be easiest to append the basisMap within the x-style method***
				% 
				% 	The mode is currently just a reproduction of the thing. so don't convolve.
				% 
				% 	Widths (ms): -- these are just dummy holders
				%
				ws = 10; 
				x_bars = {0};
				% 
				% 	Now form the basis and map in the same format as usual...
				% 
				basis{1,1} = {{1:10}, (1:10)/10}; 
				% 
				basisMap = cell(1,2);
				mapidx = 1;
				for iWs = 1:numel(ws)
					for xbar = 1:numel(x_bars{iWs})
 						basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
 						basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
						mapidx = mapidx + 1;
					end
                end
                % 
				% 	Align the features into the basisXsingle array
				% 
				[basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);

			elseif strcmpi(Mode, 'EMG')
				% 
				% 	The mode is currently just a reproduction of the thing. so don't convolve.
				% 
				% 	Widths (ms): -- these are just dummy holders
				%
				ws = 10; 
				x_bars = {0};
				% 
				% 	Now form the basis and map in the same format as usual...
				% 
				basis{1,1} = {{1:10}, (1:10)/10}; 
				% 
				basisMap = cell(1,2);
				mapidx = 1;
				for iWs = 1:numel(ws)
					for xbar = 1:numel(x_bars{iWs})
 						basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
 						basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
						mapidx = mapidx + 1;
					end
                end
                % 
				% 	Align the features into the basisXsingle array
				% 
				[basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);
				% % 
				% % 	This mode allows a set of EMG timestamps to be converted into features with blur
				% % 
				% % 	Widths (ms):
				% %
				% ws = [50, 100, 150, 200, 250]; 
				% x_bars{1} = 0;
    %             x_bars{2} = 0;
    %             x_bars{3} = 0;
    %             x_bars{4} = 0;
    %             x_bars{5} = 0;
				% % 
				% % 	Now form the basis and map in the same format as usual...
				% % 
				% basis = cellfun(@(w, x_bar) obj.makeGaussVect(w, x_bar), num2cell(ws), x_bars, 'UniformOutput', 0);
				% % 
				% basisMap = cell(1,2);
				% mapidx = 1;
				% for iWs = 1:numel(ws)
    %                 if numel(numel(x_bars{iWs})) > 1
    %                     for xbar = 1:numel(x_bars{iWs})
    %                         basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
    %                         basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
    %                         mapidx = mapidx + 1;
    %                     end
    %                 else
    %                     basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}'];
    %                     basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
    %                     mapidx = mapidx + 1;
    %                 end
    %             end
    %             % 
				% % 	Align the features into the basisXsingle array
				% % 
				% [basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);
			elseif strcmpi(Mode, 'EMGdelta')
				run_style = '2';
				% 
				% 	The mode is gauss, centering is causal (so right shift all)
				% 
				% 	The offsets from the behavioral event: (overlap is b-width (stride is 1/2))
				% 
				 % 
				if strcmp(run_style, 'full')
					% 
					% 	Widths (ms):
					%
					ws = [50, 100, 500, 1000, 5000];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'center');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 1000, 'center');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'center');
	                x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 7000, 'center');
	                x_bars{5} = obj.tileSpace(ws(5), ws(5)/2, 14000, 'center');
				elseif strcmp(run_style, '3')
					ws = [100, 500, 1000];
					x_bars = cell(1, numel(ws));
					x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 1000, 'center');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 7000, 'center');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'center');
				elseif strcmp(run_style, '2')
					ws = [75, 100,75, 100];
					x_bars = cell(1, numel(ws));
					x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'left');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 500, 'left');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 300, 'causal');
	                x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 300, 'causal');
				end	
				% 
				% 	Generate the basis set
				% 
				basis = cellfun(@(w, x_bar) obj.makeHalfCosVect(w, x_bar), num2cell(ws), x_bars, 'UniformOutput', 0);
				% 
				%	Generate the basis Map - this will let us easily jump to any of the features 
				% 
				basisMap = cell(sum(cellfun(@(x) numel(x), basis)),1);
				mapidx = 1;
				for iWs = 1:numel(ws)
					for xbar = 1:numel(x_bars{iWs})
 						basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
 						basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
						mapidx = mapidx + 1;
					end
                end
                % 
				% 	Align the features into the basisXsingle array
				% 
				[basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);	

			elseif strcmpi(Mode, 'MOVEdelta')
				run_style = '2';
				% 
				% 	The mode is gauss, centering is causal (so right shift all)
				% 
				% 	The offsets from the behavioral event: (overlap is b-width (stride is 1/2))
				% 
				 % 
				if strcmp(run_style, 'full')
					% 
					% 	Widths (ms):
					%
					ws = [50, 100, 500, 1000, 5000];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'center');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 1000, 'center');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'center');
	                x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 7000, 'center');
	                x_bars{5} = obj.tileSpace(ws(5), ws(5)/2, 14000, 'center');
				elseif strcmp(run_style, '3')
					ws = [100, 500, 1000];
					x_bars = cell(1, numel(ws));
					x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 1000, 'center');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 7000, 'center');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'center');
				elseif strcmp(run_style, '2')
					ws = [75, 100,75, 100];
					x_bars = cell(1, numel(ws));
					x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'left');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 500, 'left');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 500, 'causal');
	                x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 500, 'causal');
				end	
				% 
				% 	Generate the basis set
				% 
				basis = cellfun(@(w, x_bar) obj.makeHalfCosVect(w, x_bar), num2cell(ws), x_bars, 'UniformOutput', 0);
				% 
				%	Generate the basis Map - this will let us easily jump to any of the features 
				% 
				basisMap = cell(sum(cellfun(@(x) numel(x), basis)),1);
				mapidx = 1;
				for iWs = 1:numel(ws)
					for xbar = 1:numel(x_bars{iWs})
 						basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
 						basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
						mapidx = mapidx + 1;
					end
                end
                % 
				% 	Align the features into the basisXsingle array
				% 
				[basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);	

			elseif strcmpi(Mode, 'ramp-conv')
					run_style = '3';
					% 
					% 	Widths (ms):
					%
                if strcmp(run_style, 'full')
					ws = [50, 100, 500, 1000, 5000];
					x_bars = cell(1, numel(ws));
	                x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 500, 'causal');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 1000, 'causal');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'causal');
	                x_bars{4} = obj.tileSpace(ws(4), ws(4)/2, 7000, 'causal');
	                x_bars{5} = obj.tileSpace(ws(5), ws(5)/2, 14000, 'causal');
				elseif strcmp(run_style, '3')
					ws = [500, 1250, 2500];
					x_bars = cell(1, numel(ws));
					x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 7000, 'causal');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 7000, 'causal');
	                x_bars{3} = obj.tileSpace(ws(3), ws(3)/2, 7000, 'causal');
				else
					ws = [100, 500];
					x_bars = cell(1, numel(ws));
					x_bars{1} = obj.tileSpace(ws(1), ws(1)/2, 1000, 'causal');
	                x_bars{2} = obj.tileSpace(ws(2), ws(2)/2, 1000, 'causal');
				end	
				% 
				% 	Generate the basis set
				% 
				basis = cellfun(@(w, x_bar) obj.makeHalfCosVect(w, x_bar), num2cell(ws), x_bars, 'UniformOutput', 0);
				% 
				%	Generate the basis Map - this will let us easily jump to any of the features 
				% 
				basisMap = cell(sum(cellfun(@(x) numel(x), basis)),2);
				mapidx = 1;
				for iWs = 1:numel(ws)
					for xbar = 1:numel(x_bars{iWs})
 						basisMap{mapidx, 1} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,1}{1, ' num2str(xbar) '}'];
 						basisMap{mapidx, 2} = ['{1,' num2str(nBasis) '}{1, ' num2str(iWs) '}{1,2}'];
						mapidx = mapidx + 1;
					end
				end
				% 
				% 	Align the features into the basisXsingle array
				% 
				[basisXaxis, basisXsingle] = obj.alignFeatures(basis, basisMap);

			elseif strcmpi(Mode, 'ramp-delta')
				% 
				% 	Using the 
				% 

			elseif strcmpi(Mode, 'boxcar')


			end

		end

		function [gxy] = makeGaussVect(obj, Width, x_bar, npnts, grade)
			% 
			% 	Makes a 1xn vector of gaussian curve with width and offset from zero. There's always the same resolution between curves regardless of width
			% 
			Width = Width/2; % we will have the user put in the width they actually want, not the width as gaussian is concerned, which is actually 2*w
			if nargin < 4
				npnts = Width*10;
			end
			Range = [-npnts/2/Width, npnts/2/Width];
			if nargin < 5
				grade = 1/npnts * 10; % should give a gradation of 1ms for any case
			end
			% 
			% 	Generate enough normalized pdf points to cover the range
			% 
			gv_y = normpdf([Range(1):grade:Range(2)]);
			if numel(x_bar) > 1
                gv_x = cell(1, numel(x_bar));
                for x = 1:numel(x_bar)
                    % 
                    % 	Shift and scale the x-axis to position the gaussian where we want it.
                    % 
                    gv_x{x} = Width*(Range(1):grade:Range(2)) + x_bar(x);
                    % 
                    % 	Create the final x-shifted curve
                    % 
                 %    if xbar(x) > 0
	                %     curves{x} = horzcat(zeros(1, x_bar(x)), gv_y);
                 %    elseif xbar(x) < 0
                 %    	curves{x} = horzcat(gv_y, zeros(1, x_bar(x)));
                	% end
                end
            else
                gv_x = Width*(Range(1):grade:Range(2)) + x_bar;
                curves = {gv_y};
            end
			% 
			% 	Make a cell-tuple
			% 
			gxy = {gv_x, gv_y};
		end

		function [hcos_xy] = makeHalfCosVect(obj, Width, x_bar, npnts, xgrade)
			% 
			% 	Makes a 1xn vector of 1/2 cosine curve with width and offset from zero. There's always the same resolution between curves regardless of width
			% 
			if nargin < 4
				npnts = Width;
            end	
			if nargin < 5
				xgrade = 1; % should give a gradation of 1ms for any case
                cosgrade = pi/(npnts-1); % should give a gradation of 1ms for any case
			end
			% 
			% 	Generate enough normalized pdf points to cover the range
			% 
			hcos_y = sin(0:cosgrade:pi);
			if numel(x_bar) > 1
                hcos_x = cell(1, numel(x_bar));
                for x = 1:numel(x_bar)
                    % 
                    % 	Shift and scale the x-axis to position the gaussian where we want it.
                    % 
                    hcos_x{x} = [0:xgrade:Width-1] + x_bar(x);
                    % 
                    % 	Create the final x-shifted curve
                    % 
         %            if x_bar(x) > 0
	        %             curves{x} = horzcat(zeros(1, x_bar(x)), hcos_y);
         %            elseif x_bar(x) < 0
    					% curves{x} = horzcat(hcos_y, zeros(1, x_bar(x)));
         %        	end
                end
            else
                hcos_x = [0:xgrade:Width-1] + x_bar;
                curves = {hcos_y};
            end
			% 
			% 	Make a cell-tuple
			% 
			hcos_xy = {hcos_x, hcos_y};
		end

		function [hx2_xy] = makeTaylor2ndDerivVect(obj, Width, x_bar, npntsPerMS)
			% 
			% 	Makes a 1xn vector of -x^2 curve with width and offset from zero. There's always the same resolution between curves regardless of width
			% 
			if nargin < 4
				npntsPerMS = 1;
            end	
			% 
			% 	Generate enough -x^2 points to cover the range, then normalize
			% 
			hx2_y = -(-Width/2:npntsPerMS:Width/2).^2;
			hx2_y = hx2_y./(max(abs(hx2_y))) + 1;
			if numel(x_bar) > 1
                hx2_x = cell(1, numel(x_bar));
                for x = 1:numel(x_bar)
                    % 
                    % 	Shift and scale the x-axis to position the curve where we want it.
                    % 
                    hx2_x{x} = [-Width/2:npntsPerMS:Width/2] + x_bar(x);
                end
            else
                hx2_x = [-Width/2:npntsPerMS:Width/2] + x_bar;
                curves = {hx2_y};
            end
			% 
			% 	Make a cell-tuple
			% 
			hx2_xy = {hx2_x, hx2_y};
		end




		function x_bars = tileSpace(obj, Width, x_bar, maxW, centering)
			% 
			% 	Tiles the centering of each basis curve across all reasonable space 
			% 	(7 sec around centered or 14 sec to right of causal)
			% 
			if nargin < 4
				maxW = 7000;
            end
            if nargin < 5
				centering = 'center';
            end
            if strcmpi(centering, 'center')
    			x_bars = -maxW:x_bar:maxW;
            elseif strcmpi(centering, 'causal')
                x_bars = 0:x_bar:maxW;
                x_bars = 0:x_bar:maxW-Width;
                % warning('Trying new causal tileSpace... 11/19/18')
            elseif strcmpi(centering, 'left')
                x_bars = -maxW:x_bar:-Width/2;    
            end
		end

		function X = oneHotDesignMatrix(obj, x_rep, pos)
			% 
			% 	The x-rep is made by ramp-untrimmed Xrepresentation. Now, for each position in all ramps, we make a feature
			% 
			% 	Thus: [0 0 0 0 1 2 3 4 5 0 0 0] --> 1: [0 0 0 0 1 0 0 0 0 0 0 0]
			% 									--> 2: [0 0 0 0 0 1 0 0 0 0 0 0]
			% 	etc
			% 	To save memory, we can do this:
			% 										   [0 0 0 0 1 1 1 1 1 0 0 0]
			% 	I think we could easily downsample by 10's or even 50s...
			% 
			warning('10x downsample')
			num1s = pos(2)-pos(1);
			X = zeros(numel(pos),numel(x_rep));
			for p = 1:numel(pos)
				X(p, intersect(find(x_rep >= pos(p)), find(x_rep < pos(p)+num1s))) = 1; 
			end
		end

		function [X, th2remove] = scaledHeatDesignMatrix(obj, x_rep, posAll, nonFit)
			% 
			% 	CREATES AN OBJECTIVE TIME FEATURE!!!!!!!!!!!!!!!!!
			% 
			% 
			% 	Set to true to isolate feature from cue or lick
			% 
			isolate_cue_mode = false;
			isolate_lick_mode = true;			
			% 
            if nargin <4
                nonFit = false;
            end
			
			num1s = posAll(2)-posAll(1);
			disp([' Executing scaledHeatDesignMatrix with ' num2str(num1s), 'x downsample'])
			X = zeros(numel(posAll),numel(x_rep));
			% 
			% 	Samples in each shuffled trial
			% 
            if nonFit
                validTrialLengths = numel(x_rep);
            else
                if isfield(obj.GLM.flush, 'SnTrialsUniform')
                	validTrialLengths = obj.GLM.flush.samples_bt_c2l(obj.GLM.flush.SnTrialsUniform);	
                else
                    validTrialLengths = obj.GLM.flush.samples_bt_c2l(obj.GLM.flush.SnTrials_sub7);
                end
            end
            if isolate_cue_mode
				cue_width = 500;
            	validTrialLengths = validTrialLengths - cue_width;
            	warning(['In isolating cue mode, width ' num2str(cue_width) ' -- be sure the cue features reach up to the edge of the ramp'])
            	tStartPosInX = find(x_rep == cue_width+1);
        	else
        		tStartPosInX = find(x_rep == 1);
        	end
        	if isolate_lick_mode
				lick_width = 490;
            	validTrialLengths = validTrialLengths - lick_width;
            	warning(['In isolating lick mode, width ' num2str(lick_width) ' -- be sure the cue features reach up to the edge of the ramp'])
        	end
			% 
			% 	Seems the best way is just to go trial by trial...
			% 
            warning('We end up trimming off <10ms from the final feature this way...')
			for iTrial = 1:numel(tStartPosInX)
                if ~rem(iTrial, 20)
                    disp(['        *** Trial #', num2str(iTrial), ' -- ' datestr(now)])
                end
                if validTrialLengths(iTrial) <= 0
                	% don't want to build a ramp if there's no ramp on this trial...
                	continue
            	else
	                pos = 1:num1s:validTrialLengths(iTrial);
					for p = 1:numel(pos)-1
						X(p, tStartPosInX(iTrial)+(p-1)*num1s:tStartPosInX(iTrial)+(p-1)*num1s+num1s-1) = [pos(p):1:pos(p)+num1s-1]/validTrialLengths(iTrial);
	                end
                end
			end
			th2remove = [];
			for ifeat = 1:numel(posAll)
				if isempty(find(X(ifeat, :)>0))
					th2remove(end+1) = ifeat;
				end
			end
		end

		function [X] = stretchedTimeDesignMatrix(obj, x_rep, nonFit)
			% 
			% 	CREATES A SUBJECTIVE, stretched in x TIME FEATURE!!!!!!!!!!!!!!!!!
			% 		The idea is to represent proportions of the interval (1% - 100%...)
			% 		Max feature width would then be 
			% 
			% 		We might still want to isolate the cue and the lick from this feature, 
			% 		since they will overlap differently on different length trials. But let's start simple...	
			% 		Besides, I can't think of a good way to isolate them, because will have discontinuities at the edges
			% 			
			% 
			% 	In a new version (11/26/18), we will bin time rather than do a percentage, because percentage method 
			% 		causes undershoot or overshoot on a given trial length
			% 
			% 
            if nargin <3
                nonFit = false;
            end
            % 
            % 	We roughly want bins that will be ~ 0.2% of the trial. Of course, we can't get this exactly, so we will
            % 	tile space to be about 0.2% of the trial per bin, then give the last bin slack to rep the remainder of 
            % 	the interval. The lick feature should dominate there anyway...
            % 
			pcTrialPerBin = 0.2;
			nFeatures = round(100/pcTrialPerBin);
			nBins = nFeatures;
			X = zeros(nFeatures,numel(x_rep));
			% 
			% 	Samples in each shuffled trial
			% 
            if nonFit
                validTrialLengths = numel(x_rep);
            else
            	disp([' Executing stretchedTimeDesignMatrix with ' num2str(pcTrialPerBin), '% of the trial per bin, where each bin is a feature'])
            	if isfield(obj.GLM.flush, 'SnTrialsUniform')
                   validTrialLengths = obj.GLM.flush.samples_bt_c2l(obj.GLM.flush.SnTrialsUniform);	
                else
                    validTrialLengths = obj.GLM.flush.samples_bt_c2l(obj.GLM.flush.SnTrials_sub7);	
                end
            end
            tStartPosInX = find(x_rep == 1);
			% 
			% 	Seems the best way is just to go trial by trial...
			% 
			for iTrial = 1:numel(tStartPosInX)
                if ~rem(iTrial, 20)
                    disp(['        *** Trial #', num2str(iTrial), ' -- ' datestr(now)])
                end
                % 
                % 	We will break the trial into even numbers of bins. 
                % 		If there's some overlap because of the binning procedure, we will allow that
                % 		For the most part, we will try to avoid overlaps, though
                % 
            	binEdges = [1, ceil((1:nBins)*validTrialLengths(iTrial)/nBins)];
            	samplesPerBin = binEdges(1);
            	if ~rem(iTrial, 20)
                    disp(['        samplesPerBin ~', num2str(samplesPerBin), ' +/- 1'])
                end
                % 
                % 	Now, fill each bin from the edges
                % 
                priorPC = 0;
                idx = 0;
                for iBin = 1:nBins
                	startPos = tStartPosInX(iTrial)+idx;
                	samplesInBin = binEdges(iBin+1) - binEdges(iBin);
                    if samplesInBin == 0
                        samplesInBin = 1;
                    end
                	endPos = startPos + samplesInBin - 1;
                	% 
                	% 	Since each bin tiles a certain percentage of space, have that bin go from lastbinmaxPerc+percPerSample:thisBinPerc
                	% 
                	PCperSample = pcTrialPerBin / samplesInBin;
                	startPC = priorPC+PCperSample;
                	% 
                	binPCMax = pcTrialPerBin*iBin;
                    if isempty(startPC:PCperSample:binPCMax)
                        X(iBin, startPos:endPos) = binPCMax;
                    else
                        X(iBin, startPos:endPos) = startPC:PCperSample:binPCMax;
                    end
                	% 
                	priorPC = binPCMax;
                	idx = idx+samplesInBin;
            	end
        	end
        	% 
        	% 	Finally, since we want to normalize all features to max = 1, divide the whole matrix by 100
        	% 
        	X = X./100;
			% percentOfTrial = .2;
			% numFeatures = round(100/percentOfTrial);
			% disp([' Executing stretchedTimeDesignMatrix with ' num2str(percentOfTrial), '% per feature'])
			% X = zeros(round(100/percentOfTrial),numel(x_rep));
			% % 
			% % 	Samples in each shuffled trial
			% % 
   %          if nonFit
   %              validTrialLengths = numel(x_rep);
   %          else
   %          	validTrialLengths = obj.GLM.flush.samples_bt_c2l(obj.GLM.flush.SnTrialsUniform);	
   %          end
   %          tStartPosInX = find(x_rep == 1);
			% % 
			% % 	Seems the best way is just to go trial by trial...
			% % 
			% for iTrial = 1:numel(tStartPosInX)
   %              if ~rem(iTrial, 20)
   %                  disp(['        *** Trial #', num2str(iTrial), ' -- ' datestr(now)])
   %              end
   %              if validTrialLengths(iTrial) <= 100/percentOfTrial
   %              	% don't want to build a ramp if there's no ramp on this trial...
   %              	continue
   %          	else
   %          		samplesPerPercentFeature = ceil(validTrialLengths(iTrial)*(percentOfTrial/100));
   %          		sPPF = samplesPerPercentFeature;
   %                  samplesFor100Per = samplesPerPercentFeature * (numFeatures+1);
   %          		percentagePointsPerSample = percentOfTrial/samplesPerPercentFeature;
   %          		pPPS = percentagePointsPerSample;
			% 		for p = 1:numFeatures
   %                      startPerc = (p-1)*sPPF*pPPS+pPPS;
   %                      endPerc = (p-1)*sPPF*pPPS+pPPS*sPPF;
			% 			X(p, tStartPosInX(iTrial)+(p-1)*sPPF:tStartPosInX(iTrial)+(p-1)*sPPF+numel(startPerc:pPPS:endPerc)-1) = startPerc:pPPS:endPerc;
	  %               end
   %              end
			% end


			% 
			% 	DEBUG
			% 
			% figure,
			% hold on
			% plot(x_rep)
			% plot(sum(X, 1))
		end

		function x = makeXrepresentation(obj, event, x_style, t, t_times, eventNo)
		% 
		% 	Using the x_style command passed in as a cell, we will 
		% 	construct a 1xt timeseries representation of the event over the entire dataset
		% 
		% RECALL:	x_style:	This cell array of cells determines how we will represent the events
		% 		{'none'}		-- use raw signal
		% 		{'blur', width} -- convolves with a single gaussian of width (in ms) specified -- use with movement signals
		% 		{'delta', spread = 1} -- transforms timestamps into a one-hot. If there's a spread ~= 1 (e.g., 3), then instead of 01000 --> 01110
		% 		{'boxcar'} 		-- transforms paired timestamps into boxcars of width = distance between timestamps
		% 		{'ramp'}		-- transforms paired timestamps into a ramp of width = distance between timestamps
		% 	
		%
			disp(['	In event # ' num2str(eventNo) '.........'])
			if strcmpi(x_style{1}, 'none')
				disp('		Using raw representation. Simply trim the set, then make sure sampling rate matches and downsample as needed') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check that it's ok to downsample here...
				% 
				% 	Trim the set to match photometry size
				% 
				tsScalingFactor = 1; 
                if isfield(obj.GLM.flush, 'idxcat')
                	%  verified 4/4/19 using gfit as control for chopping
                    x_trim = event{1}; % we don't want to concat just yet because this is done at X step (obj.GLM.flush.idxcat);
                	% 
					%	Scale the stuff based on the amplitude - need to get it normalized so that all features are maxed at 1
					%
					tsScalingFactor = max(abs(x_trim(obj.GLM.flush.idxcat))); 
					x_trim = x_trim./tsScalingFactor; 
                else
                	error('RBF')
    				x_trim = obj.trimTimestamps(event{1});
    				% 
					%	Scale the stuff based on the amplitude - need to get it normalized so that all features are maxed at 1
					%
					tsScalingFactor = max(abs(x_trim)); 
					x_trim = x_trim./tsScalingFactor; 
                end
				% 
				% 	Downsample:
				% 
				if x_style{2} == 2000 || x_style{2} == 2
					x_ds = x_trim(1:2:end);
					% 
					%	Scale the stuff based on the amplitude - need to get it normalized so that all features are maxed at 1
					%
					tsScalingFactor = tsScalingFactor*max(abs(x_ds)); 
					x_ds = x_ds./(max(abs(x_ds))); 
				else
					x_ds = x_trim;
				end
				% 
				% 	Verify that the new length is correct:
				% 
				if numel(x_ds) ~= t
                    if numel(x_ds) == t+1
                        x_ds = x_ds(1:end-1);
                    elseif numel(x_ds) == t-1
                        x_ds(end+1) = x_ds(end);
                    else
    					error('The event dataset was trimmed, but it still isn''t the correct length wrt photometry set, size 1xt')
                    end
                end
                % 
                % 	Store the scaling factor in Stat
                % 
                obj.Stat.GLM.tsScalingFactor(eventNo) = tsScalingFactor;
				% 
				% maxEvent = max(max(x_ds));				% if this was 1 and data was 10, we should multiply event by maxData/maxEvent
				% maxData = max(max(obj.GLM.flush.a));
				% x_ds = x_ds .* maxData/maxEvent;
				% disp('		We scaled the data to be on same order of magnitude as the data...')
				% 
				% 	Return the new representation
				% 
				x = x_ds';

			elseif strcmpi(x_style{1}, 'autoregression')
				disp('		Using autoregression. xi = obj.GLM.gfit but shifted back by 1') %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check that it's ok to downsample here...
				% 
				% 	Autoregression shift
				% 
				autoreg_shift = x_style{2};

				% 	Shift the entire dataset to have t-1 at position 1
				% 
				event = [nan(autoreg_shift, 1); event{1}(1:end-autoreg_shift)];
				% 
				% 	Trim the set to match photometry size
				% 
				tsScalingFactor = 1;
                if isfield(obj.GLM.flush, 'idxcat')
                	warning('RBF');
                    x_trim = event; %don't want to concat yet (obj.GLM.flush.idxcat);
					% 
					% 	Scale the feature to be on same footing as other X (max 1)
					% 
					tsScalingFactor = max(abs(x_trim(obj.GLM.flush.idxcat))); 
					x_trim = x_trim./tsScalingFactor; 
                else
                	error('RBF')
    				x_trim = obj.trimTimestamps(event);
    				% 
					%	Scale the stuff based on the amplitude - need to get it normalized so that all features are maxed at 1
					%
					tsScalingFactor = max(abs(x_trim)); 
					x_trim = x_trim./tsScalingFactor; 
                end
				% 
				% 	Verify that the new length is correct:
				% 
				if numel(x_trim) ~= t
					error('The event dataset was trimmed, but it still isn''t the correct length wrt photometry set, size 1xt')
				end	
				% 
                % 	Store the scaling factor in Stat
                % 
                obj.Stat.GLM.tsScalingFactor(eventNo) = tsScalingFactor;			
				% 
				% 	Return the new representation
				% 
				x = x_trim';
			elseif strcmpi(x_style{1}, 'blur')
				disp(['		Using blurred representation, convolving with a ' num2str(x_style{2}) ' ms-wide gaussian. Then, trimming and downsampling as needed']) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% check that it's ok to downsample here...
				%
                %   Start by rectifying the signal for EMG
                %
                if strcmp(obj.Stat.GLM.eventNames{eventNo}, 'EMG')
                    disp(' *** Detected EMG data -- rectifying now...');
                    event{1} = abs(event{1});
                end
                % 
				% 	Generate the gaussian to convolve with:
				% 
				gaussfilt = obj.makeGaussVect(x_style{2},0);
				% 
				% 	Convolve with the filter
				% 
				x_conv = [conv(event{1}, gaussfilt{1,2}, 'same')'; event{2}']; 	
				% 
				% 	Trim the set to match photometry size
				% 
                if isfield(obj.GLM.flush, 'idxcat')
                    x_trim = x_conv(1,:);
                else
                    x_trim = obj.trimTimestamps(x_conv);
                end
                % 
				% 	Downsample:
				% 
				if x_style{3} == 2000 || x_style{3} == 2
					x_ds = x_trim(:, 1:2:end);
				else
					x_ds = x_trim;
				end
				% 
				% 	Verify that the new length is correct:
				% 
				if numel(x_ds(1, :)) ~= t
					error(['The event dataset was trimmed, but it still isn''t the correct length wrt photometry set, size 1xt'])
				end
				% 
				%	Scale the stuff based on the amplitude - need to get it on same order of magnitiude as actual data... 
				% 
				maxEvent = max(max(x_ds));				% if this was 1 and data was 10, we should multiply event by maxData/maxEvent
				maxData = max(max(obj.GLM.flush.a));
				x_ds = x_ds .* 100* maxData/maxEvent;
				disp('		We scaled the data to be on same order of magnitude as the data...')
				% 
				% 	Return the new representation
				% 
				x = x_ds(1, :);
				% 
				% 
			elseif strcmpi(x_style{1}, 'EMGdelta')
				disp(['		Getting EMG events and then using delta--setting threshold for event at 2std of rectified signal']) 
				%
                %   Start by rectifying the signal for EMG
                %
                if strcmp(obj.Stat.GLM.eventNames{eventNo}, 'EMGdelta')
                    disp(' *** Detected EMG data -- rectifying now...');
                    event{1} = abs(event{1});
                    % 
                    % 	Threshold and get stamps
                    % 
                    aboveT = find(event{1}(2:end) > 2*std(event{1}));
                    threshd = aboveT(ismember(aboveT, find(event{1}(1:end-1) < 2*std(event{1}))));
                    % 
                    % 	Get timestamps of these events in sec...
                    % 
                    timestamps_s = obj.GLM.emgTimes(threshd);
                    event{1} = timestamps_s;
                else
                	error(['Hey pardnah! This ain''t EMG data...'])
                end
                disp(['		Using one-hot representation of discrete event. Spread of 1''s to the right of the event is: ' num2str(x_style{2})])
				% 
				% 	Trim timestamps
				% 
				x_t_pos = obj.trimTimestamps(event);
				% 
				%   Populate the one-hot using t_times, which has the timestamp for each position in the t-array
				%
				onehot = zeros(1, t);
				if x_style{2} > 1
					for ispread = 1:x_style{2}
						extraspots = x_t_pos + ispread;
						x_t_pos = horzcat(x_t_pos, extraspots);
					end
					x_t_pos = x_t_pos(find(x_t_pos < t));
				end
				onehot(x_t_pos) = 1;
				% 
				x = onehot;
				% 
				% 
			elseif strcmpi(x_style{1}, 'MOVEdelta')
				disp(['		Getting Movement events and then using delta--setting threshold for event at UI-specified std of rectified signal']) 
				%
                %   Start by rectifying the signal for EMG
                %
                if strcmp(obj.Stat.GLM.eventNames{eventNo}, 'MOVEdelta')
                    disp(' *** Detected MOVE data -- You should have already rectified (or bandpassed for X) this... However, timestamping isn''t dependent on this really...');
                    event{1} = abs(event{1});
                    if ~isempty(x_style{2})
                    	STDmultiplier = x_style{2};
                	else
                		warning('Failed to specify STDmultiplier in x_style = {''MOVEdelta'', STDmultiplier}. Using 3 (default)')
                		STDmultiplier = 3;
            		end
                    % 
                    % 	Threshold and get stamps
                    % 
                    aboveT = find(event{1}(2:end) > STDmultiplier*std(event{1}));
                    threshd = aboveT(ismember(aboveT, find(event{1}(1:end-1) < STDmultiplier*std(event{1}))));
                    % 
                    % 	Get timestamps of these events in sec...
                    % 
                    timestamps_s = obj.GLM.MOVEtimes(threshd);
                    event{1} = timestamps_s;
                else
                	error(['Hey pardnah! This ain''t MOVE data...'])
                end
                disp(['		Using one-hot representation of discrete event. Spread of 1''s to the right of the event is: ' num2str(x_style{2})])
				% 
				% 	Trim timestamps
				% 
				x_t_pos = obj.trimTimestamps(event);
				% 
				%   Populate the one-hot using t_times, which has the timestamp for each position in the t-array
				%
				onehot = zeros(1, t);
				if x_style{2} > 1
					for ispread = 1:x_style{2}
						extraspots = x_t_pos + ispread;
						x_t_pos = horzcat(x_t_pos, extraspots);
					end
					x_t_pos = x_t_pos(find(x_t_pos < t));
				end
				onehot(x_t_pos) = 1;
				% 
				x = onehot;
				% 
				% 
			elseif strcmpi(x_style{1}, 'EMGdeltaNOlick')
				disp(['		Getting EMG events EXCLUDING WITHIN 500ms of LICK and then using delta--setting threshold for event at 2std of rectified signal']) 
				%
                %   Start by rectifying the signal for EMG
                %
                if strcmp(obj.Stat.GLM.eventNames{eventNo}, 'EMGdeltaNOlick')
                    disp(' *** Detected EMG data -- rectifying now...');
                    event{1} = abs(event{1});
                    % 
                    % 	Threshold and get stamps
                    % 
                    aboveT = find(event{1}(2:end) > 2*std(event{1}));
                    threshd = aboveT(ismember(aboveT, find(event{1}(1:end-1) < 2*std(event{1}))));
                    % 
                    % 	Get timestamps of these events in sec...
                    % 
                    timestamps_s = obj.GLM.emgTimes(threshd);
                    % 
                    % 	Now, remove any that are within 500ms of the f_lick...
                    % 		Find those licks within 500ms
                    licktrim = timestamps_s;
                    overlaps = rangesearch(timestamps_s,obj.GLM.firstLick_s,0.5);
                    licktrim([overlaps{:}]) = [];
                    event{1} = licktrim;
                else
                	error(['Hey pardnah! This ain''t EMG data...'])
                end
                disp(['		Using one-hot representation of discrete event. Spread of 1''s to the right of the event is: ' num2str(x_style{2})])
				% 
				% 	Trim timestamps
				% 
				x_t_pos = obj.trimTimestamps(event);
				% 
				%   Populate the one-hot using t_times, which has the timestamp for each position in the t-array
				%
				onehot = zeros(1, t);
				if x_style{2} > 1
					for ispread = 1:x_style{2}
						extraspots = x_t_pos + ispread;
						x_t_pos = horzcat(x_t_pos, extraspots);
					end
					x_t_pos = x_t_pos(find(x_t_pos < t));
				end
				onehot(x_t_pos) = 1;
				% 
				x = onehot;
				% 
				% 
				% 
                % 	Since we're going to the trouble of figuring this out, let's plot aligned data to this point
                % 
                % if ~isfield(obj.GLM, 'LTAemgAlignedGFit')
            	% 
            	%	Be sure to exclude any times in the ITI!! 
            	%
            	obj.GLM.LTAemgAlignedGFit = [];
            	obj.GLM.LTAemgTimes = [];
            	valid_trials = obj.GLM.fLick_trial_num;
				invalid_trials = find(~ismember(1:obj.iv.num_trials, obj.GLM.fLick_trial_num));
				lights_off_s = obj.GLM.lampOff_s(valid_trials);
				f_lick_s = zeros(1, numel(lights_off_s));
				f_lick_s(valid_trials) = obj.GLM.firstLick_s;
            	% 
            	% 	Let's show 10 s on either side... probably need to do a running average or will take up too much space
            	% 
            	obj.GLM.LTAemgAlignedGFit = zeros(1, 20001);
            	% 
            	% 	Pad the gfit
            	% 
            	padgFit = [zeros(1,10000), obj.GLM.gfit', zeros(1,10000)];
            	padPos = x_t_pos + 10000;
            	n = 1;
            	for iEMG = 1:numel(padPos)
            		%------------------------- IN PROGRESS ----------------------------------------------------------------------------
            		% 
            		% 	Get trial that this stamp is assos with
            		% 
            		trial = find(licktrim(iEMG) > lights_off_s, 1, 'last');
            		% 
            		% 	If the EMG time is not in range of trial (lampOff to flick), exclude it
            		% 
            		if isempty(trial)  || licktrim(iEMG) - lights_off_s(trial) > f_lick_s(trial) - lights_off_s(trial)
            			% pass 
						else
                		obj.GLM.LTAemgAlignedGFit = iterAve(obj, padgFit(padPos(iEMG)-10000:padPos(iEMG)+10000), obj.GLM.LTAemgAlignedGFit, n);
                		obj.GLM.LTAemgTimes(end+1) = f_lick_s(trial) - licktrim(iEMG);
                		n = n + 1;
            		end
            		%------------------------- IN PROGRESS ----------------------------------------------------------------------------
        		end
            	% end
        		figure, subplot(1,2,1), plot([-10:0.001:10], obj.GLM.LTAemgAlignedGFit)
        		title('Non-F-Lick Timing Interval EMG-aligned Average gFit')
        		xlim('Time from EMG spike (s)')
        		subplot(1,2,2), histogram(obj.GLM.LTAemgTimes), title('Histogram of EMG spike positions before flick')
			elseif strcmpi(x_style{1}, 'delta')
				disp(['		Using one-hot representation of discrete event. Spread of 1''s to the right of the event is: ' num2str(x_style{2})])
				% 
				% 	Trim timestamps
				% 
				x_t_pos = obj.trimTimestamps(event);
				% 
				%   Populate the one-hot using t_times, which has the timestamp for each position in the t-array
				%
				onehot = zeros(1, t);
				if x_style{2} > 1
					for ispread = 1:x_style{2}
						extraspots = x_t_pos + ispread;
						x_t_pos = horzcat(x_t_pos, extraspots);
					end
					x_t_pos = x_t_pos(find(x_t_pos < t));
				end
				onehot(x_t_pos) = 1;
				% 
				x = onehot;
				% 
				% 
			elseif strcmpi(x_style{1}, 'boxcar')
				disp('		Using boxcar representation of time interval -- for varying baseline based on interval.')
				% 
				% 	Trim timestamps and get number of timepoints in each ramp for scaling.
				% 		NB n_pre and n_post zero if no "hanging" events. If hanging, will add ramp points
				% 		before or after based on n_pre, n_post
				% 
				Xtrim = obj.trimTimestamps(event);
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				for ibox = 1:numel(n)
                    if ~isnan(n(ibox))
    					% onehot(event1pos(ibox)+1:event1pos(ibox)+round(n(ibox))) = ones(1,round(n(ibox))).*round(n(ibox));
    					onehot(event1pos(ibox)+1:event2pos(ibox)) = ones(1,event2pos(ibox)-event1pos(ibox)).*round(n(ibox));
                    end
				end
				% 
				%	If there's a pre-ramp... 
				% 
				if n_pre
					error('haven''t validated preramp methods yet...')
					ibox = ones(1,n_pre)/n_pre;
					startpos = n_pre - numel(1:event2pos(1)) + 1;
					onehot(1:event2pos(1)) = ibox(startpos:end);
				end
				% 
				%	If there's a post-ramp... 
				% 
				if n_post
					error('haven''t validated post-ramp methods yet...')
					ibox = ones(1,n_post)/n_post;
					endpos = numel(onehot) - event1pos(end);
					onehot(event1pos(end)+1:end) = ibox(1:endpos);
				end
				% 
				% 	Finally, normalize to the longest possible interval (we will say 7000 max, since that's the max length of the trial from cue-on)
				% 
				onehot = onehot./7000;
				% 
                x = onehot;
				% % 
				% % 	Trim timestamps
				% % 
				% x_t_pos = obj.trimTimestamps(event);
				% % 
				% %   Populate the one-hot using t_times, which has the PAIR of timestamps for each position in the t-array
				% %
				% onehot = zeros(1, t);
				
				% if rem(numel(x_t_pos), 2) == 0
				% 	pos1 = 1:2:numel(x_t_pos)-1;
				% 	pos2 = 2:2:numel(x_t_pos);
				% else
				% 	warning('Dectected uneven number of paired timestamps in BOXCAR contruction. I think you should only have even...')
				% 	pos1 = 1:2:numel(x_t_pos);
				% 	pos2 = 2:2:numel(x_t_pos)-1;
				% end
				% for ipair = 1:numel(pos2)
				% 	onehot(x_t_pos(pos1(ipair)):x_t_pos(pos2(ipair))) = 1;
				% end
				% % 
				% x = onehot;
				% % 
				% 
			elseif strcmpi(x_style{1}, 'boxcar-ones')
				disp('		Using boxcar representation of time interval -- ALL ONES.')
				% 
				% 	Trim timestamps and get number of timepoints in each ramp for scaling.
				% 		NB n_pre and n_post zero if no "hanging" events. If hanging, will add ramp points
				% 		before or after based on n_pre, n_post
				% 
				Xtrim = obj.trimTimestamps(event);
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				for ibox = 1:numel(n)
					onehot(event1pos(ibox)+1:event1pos(ibox)+round(n(ibox))) = ones(1,round(n(ibox))).*1;
				end
				% 
				%	If there's a pre-ramp... 
				% 
				if n_pre
					warning('haven''t validated preramp methods yet...')
					ibox = ones(1,n_pre);
					startpos = n_pre - numel(1:event2pos(1)) + 1;
					onehot(1:event2pos(1)) = ibox(startpos:end);
				end
				% 
				%	If there's a post-ramp... 
				% 
				if n_post
					ibox = ones(1,n_post);
					endpos = numel(onehot) - event1pos(end);
					onehot(event1pos(end)+1:end) = ibox(1:endpos);
				end
				% 
				% 	Finally, normalize to the longest possible interval (we will say 7000 max, since that's the max length of the trial from cue-on)
				% 
				% onehot = onehot./7000;
				% 
                x = onehot;
				
			elseif strcmpi(x_style{1}, 'ramp')
				disp('		Using scaled (normalized to 1 at peak) ramp representation of time interval (1 unit/ms).')
				runMode = 'fullInterval';
				rightOfCuePos = 500*round(obj.Plot.samples_per_ms);
				leftOfLickPos = 500*round(obj.Plot.samples_per_ms);
				% 
				% 	Trim timestamps and get number of timepoints in each ramp for scaling.
				% 		NB n_pre and n_post zero if no "hanging" events. If hanging, will add ramp points
				% 		before or after based on n_pre, n_post
				% 
				Xtrim = obj.trimTimestamps(event);
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				if strcmp(runMode, 'fullInterval')
					for iramp = 1:numel(n)
						onehot(event1pos(iramp)+1:event1pos(iramp)+round(n(iramp))) = [1:round(n(iramp))]./round(n(iramp));
					end
					% 
					%	If there's a pre-ramp... 
					% 
					if n_pre
						warning('haven''t validated preramp methods yet...')
						ramp = [1:n_pre]/n_pre;
						startpos = n_pre - numel(1:event2pos(1)) + 1;
						onehot(1:event2pos(1)) = ramp(startpos:end);
					end
					% 
					%	If there's a post-ramp... 
					% 
					if n_post
						ramp = [1:n_post]/n_post;
						endpos = numel(onehot) - event1pos(end);
						onehot(event1pos(end)+1:end) = ramp(1:endpos);
					end
				elseif strcmp(runMode, 'trimInterval')
					for iramp = 1:numel(n)
						onehot(event1pos(iramp)+1+rightOfCuePos:event1pos(iramp)+round(n(iramp))-leftOfLickPos) = [1:round(n(iramp)-leftOfLickPos-rightOfCuePos)]./round(n(iramp)-leftOfLickPos-rightOfCuePos);
					end
					% 
					%	If there's a pre-ramp... 
					% 
					if n_pre
						warning('haven''t validated preramp methods yet...')
						ramp = [1:n_pre-leftOfLickPos]/(n_pre-leftOfLickPos-rightOfCuePos);
						startpos = n_pre - numel(1:event2pos(1)) + 1;
						onehot(1:event2pos(1)-leftOfLickPos) = ramp(startpos:end-leftOfLickPos);
					end
					% 
					%	If there's a post-ramp... 
					% 
					if n_post
						ramp = [1:n_post-rightOfCuePos]/(n_post-leftOfLickPos-rightOfCuePos);
						endpos = numel(onehot) - event1pos(end)-rightOfCuePos;
						onehot(event1pos(end)+1+rightOfCuePos:end) = ramp(1:endpos);
					end
				else
					error('runMode not specified correctly')
				end
				
				% 
				% 
                x = onehot;
            elseif strcmpi(x_style{1}, 'ramp-uncapped')
				disp('		Using unscaled ramp representation of time interval (1 unit/ms) -- normalized to a 7sec interval.')
				% 
				% 	Trim timestamps and get number of timepoints in each ramp for scaling.
				% 		NB n_pre and n_post zero if no "hanging" events. If hanging, will add ramp points
				% 		before or after based on n_pre, n_post
				% 
				% 	 NORMALIZED TO 7000 FOR END OF TRIAL!
				% 
				Xtrim = obj.trimTimestamps(event);
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				for iramp = 1:numel(n)
					onehot(event1pos(iramp)+1:event1pos(iramp)+round(n(iramp))) = [1:round(n(iramp))]./7000;
				end
				% 
				%	If there's a pre-ramp... 
				% 
				if n_pre
					warning('haven''t validated preramp methods yet...')
					ramp = [1:n_pre]/7000;
					startpos = n_pre - numel(1:event2pos(1)) + 1;
					onehot(1:event2pos(1)) = ramp(startpos:end);
				end
				% 
				%	If there's a post-ramp... 
				% 
				if n_post
					ramp = [1:n_post]/7000;
					endpos = numel(onehot) - event1pos(end);
					onehot(event1pos(end)+1:end) = ramp(1:endpos);
				end
				% 
				% 
                x = onehot;    
            elseif strcmpi(x_style{1}, 'ramp-untrimmed')
				disp('		Using unscaled ramp representation of time interval (1 unit/ms) -- NOT normalized to a 7sec interval.')
				% 
				% 	Same as ramp-uncapped, except not normalized.
				% 
				Xtrim = obj.trimTimestamps(event);
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				for iramp = 1:numel(n)
					onehot(event1pos(iramp)+1:event1pos(iramp)+round(n(iramp))) = [1:round(n(iramp))];
				end
				% 
				%	If there's a pre-ramp... 
				% 
				if n_pre
					warning('haven''t validated preramp methods yet...')
					ramp = [1:n_pre];
					startpos = n_pre - numel(1:event2pos(1)) + 1;
					onehot(1:event2pos(1)) = ramp(startpos:end);
				end
				% 
				%	If there's a post-ramp... 
				% 
				if n_post
					ramp = [1:n_post];
					endpos = numel(onehot) - event1pos(end);
					onehot(event1pos(end)+1:end) = ramp(1:endpos);
				end
				% 
				% 
                x = onehot;    
                % 
                % 	Preserve the number of samples in each trial for use later...
                % 
                obj.GLM.flush.samples_bt_c2l = n;
                % 
                % 	Finally, update the basis map to match this method
                % 
                % 
                % 
            elseif strcmpi(x_style{1}, 'poly-set')
            	% x_style = {'poly-set', order}
				disp('		Making set of polynomial ramps: x^n -- all reach to 1 at end of interval')
				% 
				% 	Trim timestamps and get number of timepoints in each ramp for scaling.
				% 		NB n_pre and n_post zero if no "hanging" events. If hanging, will add ramp points
				% 		before or after based on n_pre, n_post
				% 
				Xtrim = obj.trimTimestamps(event);
				poly_order = x_style{2};
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				for iramp = 1:numel(n)
					onehot(event1pos(iramp)+1:event1pos(iramp)+round(n(iramp))) = ([1:round(n(iramp))]/round(n(iramp))).^poly_order;
				end
				% 
				%	If there's a pre-ramp... 
				% 
				if n_pre
					warning('haven''t validated preramp methods yet...')
					ramp = ([1:n_pre]/n_pre).^poly_order;
					startpos = n_pre - numel(1:event2pos(1)) + 1;
					onehot(1:event2pos(1)) = ramp(startpos:end);
				end
				% 
				%	If there's a post-ramp... 
				% 
				if n_post
					ramp = ([1:n_post]/n_post).^poly_order;
					endpos = numel(onehot) - event1pos(end);
					onehot(event1pos(end)+1:end) = ramp(1:endpos);
				end
				% 
				% 
                x = onehot;
            elseif strcmpi(x_style{1}, 'exp-set')
				% x_style = {'exp-set', order}
				disp('		Making set of exponential ramps: exp^n*x -- all reach to 1 at end of interval')
				% 
				% 	Trim timestamps and get number of timepoints in each ramp for scaling.
				% 		NB n_pre and n_post zero if no "hanging" events. If hanging, will add ramp points
				% 		before or after based on n_pre, n_post
				% 
				Xtrim = obj.trimTimestamps(event);
				exp_order = x_style{2};
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				for iramp = 1:numel(n)
					onehot(event1pos(iramp)+1:event1pos(iramp)+round(n(iramp))) = exp(([1:round(n(iramp))]/round(n(iramp))).*exp_order) - 1;
				end
				% 
				%	If there's a pre-ramp... 
				% 
				if n_pre
					warning('haven''t validated preramp methods yet...')
					ramp = exp*(([1:n_pre]/n_pre).*exp_order) - 1;
					startpos = n_pre - numel(1:event2pos(1)) + 1;
					onehot(1:event2pos(1)) = ramp(startpos:end);
				end
				% 
				%	If there's a post-ramp... 
				% 
				if n_post
					ramp = exp(([1:n_post]/n_post).*exp_order) - 1;
					endpos = numel(onehot) - event1pos(end);
					onehot(event1pos(end)+1:end) = ramp(1:endpos);
				end
				% 
				% 
                x = onehot;
            elseif strcmpi(x_style{1}, 'rad-set')
				% x_style = {'exp-set', order}
				disp('		Making set of radical ramps: x^-n -- all reach to 1 at end of interval')
				% 
				% 	Trim timestamps and get number of timepoints in each ramp for scaling.
				% 		NB n_pre and n_post zero if no "hanging" events. If hanging, will add ramp points
				% 		before or after based on n_pre, n_post
				% 
				Xtrim = obj.trimTimestamps(event);
				exp_order = x_style{2};
                %
                %
                %
                event1pos = Xtrim{1};
                event2pos = Xtrim{2};
                n = Xtrim{3}; 
                n_pre = Xtrim{4};
                n_post = Xtrim{5};
				% 
				%	Construct ramps for the clean deltas starting at event 1 
				%
				onehot = zeros(1, t);
				% 
				for iramp = 1:numel(n)
					onehot(event1pos(iramp)+1:event1pos(iramp)+round(n(iramp))) = ([1:round(n(iramp))]/round(n(iramp))).^exp_order;
				end
				% 
				%	If there's a pre-ramp... 
				% 
				if n_pre
					warning('haven''t validated preramp methods yet...')
					ramp = ([1:n_pre]/n_pre).^exp_order;
					startpos = n_pre - numel(1:event2pos(1)) + 1;
					onehot(1:event2pos(1)) = ramp(startpos:end);
				end
				% 
				%	If there's a post-ramp... 
				% 
				if n_post
					ramp = ([1:n_post]/n_post).^exp_order;
					endpos = numel(onehot) - event1pos(end);
					onehot(event1pos(end)+1:end) = ramp(1:endpos);
				end
				% 
				% 
                x = onehot;
            elseif strcmp(x_style{1}, 'ssStretch')
            	% 
            	% 	Sam Stretch x-rep tool (3/25/19)            	
            	% 
				% 	event = {obj.GLM.cue_s, obj.GLM.firstLick_s}; % this will make the ramp from cue to fLick
				% 	ssBins = [1000:500:7000]; % then we will do an x-rep for each bin
				% 	ssConstrained = false; % set to true if want to constrain the F? curves
				% 	for ssBin in ssBins: (bin is >=binMin <binMax)
				% 		x_style = {‘sStretch-impulse', ssBin, ssConstrained}
				% 			OR
				% 		x_style = {‘sStretch-dF2', ssBin, ssConstrained}
				% 	t and t_times are defaults (makes consistent with all other stuff)
				% 
				% 	It makes sense to do the dF2 at same time. so output (x) = {2,1} cell with impulse first, dF2 second
				% 
				% 	*** IF there's more than one bin, we will also do this here and start building up the X feature
				% 
				if ~isfield(obj.GLM, 'flush') || ~isfield(obj.GLM.flush, 'ssWidth_ms')
					obj.GLM.flush.ssWidth_ms = 100;
					warning('Using default ssWidth = 100ms because not found in GLM.flush')
				end
				if ~isfield(obj.GLM.flush, 'ssFeatureIdxs')
					obj.GLM.flush.ssFeatureIdxs_impulse = []; % column 1 will be the BIN - feature # is implied
					obj.GLM.flush.ssFeatureIdxs_dF2 = []; % column 1 will be the BIN
				end
				nbins = numel(event{3}) - 1;
				for ibin = 1:nbins
					
					binMin = event{3}(ibin);
					binMax = event{3}(ibin+1);
					if binMax > 100
						binMin = binMin/1000;
						binMax = binMax/1000;
					end
					disp(['		Using ssStretch Impulse for bin-span: ' num2str(binMin) ':' num2str(binMax) 'ms with impulse-width = ' num2str(obj.GLM.flush.ssWidth_ms) 'ms.'])
					% 
					% 	First, remove any trials from the event stamps that aren't in range for this bin
					% 
					if ~isfield(obj.GLM, 'ltbt_s')
						obj.GLM.ltbt_s = zeros(size(obj.GLM.cue_s));
						obj.GLM.ltbt_s(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
					end
					% 
					% 	Delete any not-to-include lick times and trial numbers
					% 
					idxsInRange = find(obj.GLM.ltbt_s >= binMin & obj.GLM.ltbt_s < binMax);
	                % trim off indicies not included in trial set
	                idxsInRange = obj.GLM.flush.SnTrials(ismember(obj.GLM.flush.SnTrials, idxsInRange));
					ltbt_s_trim = obj.GLM.ltbt_s(idxsInRange);
					%ltbt_trialIdx_trim = obj.GLM.fLick_trial_num(ismember(obj.GLM.fLick_trial_num,idxsInRange));
	                Xtrim = obj.trimTimestamps(obj.GLM.cue_s(idxsInRange));
	                % 
	                %
	                n = ltbt_s_trim*1000*round(obj.Plot.samples_per_ms); 
					% 
					%	We now need to insert a delta into the vector spaced by obj.GLM.flush.ssWidth
					% 		Keep in mind we later need to split this into a feature for each delta...
					% 		To do so, I'll keep track of which feature each delta goes with by giving it a relative feature index
					% 		eg: [0001000200030004000000000100020003000000001000200030004000500060007...etc]
					%
					ximpulse = zeros(1, t);
					xdF2 = zeros(1, t);
					% 
					% obj.GLM.flush.deltaIdx(deltaIdx).featureIdx = zeros(1, t);
					for itrial = 1:numel(n)
						ximpulse(Xtrim(itrial)+obj.GLM.flush.ssWidth_ms:obj.GLM.flush.ssWidth_ms:Xtrim(itrial)+round(n(itrial))) = 1:numel(Xtrim(itrial)+obj.GLM.flush.ssWidth_ms:obj.GLM.flush.ssWidth_ms:Xtrim(itrial)+round(n(itrial)));
						% obj.GLM.flush.deltaIdx(deltaIdx).featureIdx = 
					end
					% 
					%	If constrained, let's now split the ximpulse into an X:
					% 
					if ~x_style{2}
						Ximpulse = zeros(max(ximpulse), t);
						XdF2 = zeros(max(ximpulse), t);
						for iImpulse = 1:max(ximpulse)
							idxs = find(ximpulse == iImpulse);
							Ximpulse(iImpulse, idxs) = 1;
							XdF2(iImpulse, :) = obj.convX_basisCos(Ximpulse(iImpulse, :), obj.GLM.flush.dF2kernel{2}, -obj.GLM.flush.ssWidth_ms/2-1);
							obj.GLM.flush.ssFeatureIdxs_impulse(end+1, 1) = ibin;
							obj.GLM.flush.ssFeatureIdxs_dF2(end+1, 1) = ibin;
						end
					else
						Ximpulse = ximpulse>0;
						% 
						% 	Now, convolve the ximpulse with the dF2 kernel to get the xdF2 vector
						% 
						XdF2 = obj.convX_basisCos((ximpulse > 0), obj.GLM.flush.dF2kernel{2}, -obj.GLM.flush.ssWidth_ms/2-1);
						obj.GLM.flush.ssFeatureIdxs_dF2(end+1, 1) = ibin;
	                    %
	                    %   Finish making Ximpulse feature
	                    %
	                    Ximpulse = zeros(max(ximpulse), t);
						for iImpulse = 1:max(ximpulse)
							idxs = find(ximpulse == iImpulse);
							Ximpulse(iImpulse, idxs) = 1;
							obj.GLM.flush.ssFeatureIdxs_impulse(end+1, 1) = ibin;
						end
					end
					% 
					% 
	                x{ibin, 1} = Ximpulse;
	                x{ibin, 2} = XdF2;    
				end
			end
		end

		function Xtrim = trimTimestamps(obj, preXtrim_s)
		% 
		% 	Convert to positions and then trim off unneeded stamps. For analog data, just cut down to match the chunk of photometry sampled.
		% 
			if size(preXtrim_s, 2) == 1
				if isfield(obj.GLM.flush, 'idxcat')
					% 
					% 	Just convert to positions relative to the gfit times
					% 
                    if iscell(preXtrim_s)
                        Xtrim = round(preXtrim_s{1} * 1000) + 1;
                    else
    					Xtrim = round(preXtrim_s * 1000) + 1;
                    end
				else
					% 
					% 	Get event positions
					% 
					trim_pos = obj.getXPositionsWRTgfit(preXtrim_s);
					% 
					% 	Trim un-needed postions
					% 
					Xtrim = trim_pos(trim_pos >= obj.GLM.pos.pos1 & trim_pos <= obj.GLM.pos.pos2);
					% 
					% 	Finally, subtract the start position to align to the photometry data
					% 
					Xtrim = Xtrim - obj.GLM.pos.pos1+1;
				end
			elseif size(preXtrim_s, 2) == 2 
				disp('	Trimming timestamps for paired events.......')
				
				if size(preXtrim_s{1},1) ~= size(preXtrim_s{2},1) 
					if (numel(preXtrim_s{1}) == numel(obj.GLM.cue_s))  && (sum(preXtrim_s{1} == obj.GLM.cue_s) == numel(preXtrim_s{1}))
						disp('Cue detected as the first event, flick as event2')
						% 
						% 	It's assumed flick is event2
						% 
						if ~(sum(preXtrim_s{2} == obj.GLM.firstLick_s) == numel(preXtrim_s{2}))
							error('Not implemented')
						end
						%				
						% 	Get paired events. If no partner event, the timing window should end at 7s post cue default
						% 
						delTimes = nan(1, obj.iv.num_trials);
						valid_event1 = preXtrim_s{1}(obj.GLM.fLick_trial_num);
						invalid_trials = find(~ismember(1:obj.iv.num_trials, obj.GLM.fLick_trial_num));
						event2 = preXtrim_s{2};
						delTimes(obj.GLM.fLick_trial_num) = event2 - valid_event1;
						delTimes(invalid_trials) = 7.0;
					elseif (numel(preXtrim_s{1}) == numel(obj.GLM.lampOff_s)) && (sum(preXtrim_s{1} == obj.GLM.lampOff_s) == numel(preXtrim_s{1}))
						disp('Lamp-Off detected as the first event')
						% 
						% 	For flick as event2:
						% 
						if sum(preXtrim_s{2} == obj.GLM.firstLick_s) == numel(preXtrim_s{2})
							disp('fLick detected as the 2nd event')
							delTimes = nan(1, obj.iv.num_trials);
							valid_event1 = preXtrim_s{1}(obj.GLM.fLick_trial_num);
							invalid_trials = find(~ismember(1:obj.iv.num_trials, obj.GLM.fLick_trial_num));
							event2 = preXtrim_s{2};
							delTimes(obj.GLM.fLick_trial_num) = event2 - valid_event1;
						else
							error('Not implemented')
						end
					end
				else % If timestamps are = length, must be a cue and lamp off event
					% 
					% 	For lampOff as event 1, cue as event2:
					% 
					if sum(preXtrim_s{2} == obj.GLM.cue_s) == numel(preXtrim_s{2})
						disp('LampOff detected as 1st event, Cue detected as the 2nd event. NOTE HERE WE CARE ABOUT TIMING INTERVAL, NOT LampOFF to Cue interval!!!')
						delTimes = nan(1, obj.iv.num_trials);
						valid_event1 = preXtrim_s{1}(obj.GLM.fLick_trial_num);
						invalid_trials = find(~ismember(1:obj.iv.num_trials, obj.GLM.fLick_trial_num));
						event2 = preXtrim_s{2}(obj.GLM.fLick_trial_num);
						delTimes(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
					else
						error('Not implemented');
					end
				end
				% 
				% 	Trim timestamp #1 first
				% 		Get event positions
				% 
				if isfield(obj.GLM.flush, 'idxcat')
					% 
					% 	Just convert to positions relative to the gfit times
					% 
					Xtrim1 = preXtrim_s{1};%round(valid_event1(1) * 1000) + 1;
					Xtrim1 = round(Xtrim1*obj.Plot.samples_per_ms*1000);
					Xtrim2(obj.GLM.fLick_trial_num) = event2;%round(event2(end) * 1000) - 1;
					Xtrim2(invalid_trials) = preXtrim_s{1}(invalid_trials) + 7.0;
					Xtrim2 = round(Xtrim2*obj.Plot.samples_per_ms*1000);
					n1 = 0;
					n2 = 0;
					delTimes = delTimes*obj.Plot.samples_per_ms*1000;
					% 
					% 	Xtrim = {event1pos, event2pos, delTimes_trim_samples, n1, n2}, for use by the calling method
					%
					Xtrim = {Xtrim1, Xtrim2, delTimes, n1, n2};
					
				else
					trim_pos1 = obj.getXPositionsWRTgfit(valid_event1);
					% 
					% 	Trim un-needed postions
					% 
					Xtrim1 = trim_pos1(trim_pos1 >= obj.GLM.pos.pos1 & trim_pos1 <= obj.GLM.pos.pos2);
					% 
					% 	Finally, subtract the start position to align to the photometry data
					% 
					Xtrim1 = Xtrim1 - obj.GLM.pos.pos1+1;
					% 
					% 	Trim timestamp #2 next
					% 		Get event positions
					%
					trim_pos2 = obj.getXPositionsWRTgfit(preXtrim_s{2});
					% 
					% 	Trim un-needed postions
					% 
					Xtrim2 = trim_pos2(trim_pos2 >= obj.GLM.pos.pos1 & trim_pos2 <= obj.GLM.pos.pos2);
					% 
					% 	Finally, subtract the start position to align to the photometry data
					% 
					Xtrim2 = Xtrim2 - obj.GLM.pos.pos1+1;
					% 
					%	Check for no events... 
					% 
					if isempty(Xtrim1)
						error('There is no event 1 (cue) in range, can''t calculate paired-event representation')
					end
					if isempty(Xtrim2)
						error('There is no event 2 (lick) in range, can''t calculate paired-event representation')
					end
					% 
					% 	Now, figure out if there are any unmatched timestamps:
					% 
					%		Number of ramp points before and after last event...
					n1 = 0;
					n2 = 0;
					if numel(Xtrim1) ~= numel(Xtrim2)
						disp('		! Detected unpaired events. Parsing..........')
						% 
						% 	Figure out the direction of mismatch and number of stamps between the edges to include ramps
						% 	BE CAREFUL OF UNMATCHED EVENTS will need to handle that too
						% 
						preRamp = Xtrim1(1) > Xtrim2(1);
						% 
						% 	If lick is first, we should make a ramp up until this point based on the PRIOR event	
						% 
						if preRamp
	                        warning('preRamp method not validated, so be sure to check it!')
							preEvent1 = trim_pos1(find(trim_pos1 < obj.GLM.pos.pos1, 1, 'last'));
							% 
							% 	Get n points in pre-cut-off ramp: (samples)
							% 
							n1 = Xtrim2(1) - preEvent1 - obj.GLM.pos.pos1+1;
						end
						% 
						% 	Now check for a post ramp (if cue is the last event)
						% 
						postRamp = Xtrim1(end) > Xtrim2(end);
						if postRamp
							nextEvent2 = trim_pos2(find(trim_pos2 > obj.GLM.pos.pos2, 1, 'first'));
							% 
							% 	Make sure this is an appropriate event
							% 
							if nextEvent2 - (Xtrim1(end) + obj.GLM.pos.pos1-1) > 18000
								warning('		The next event-2 outside of the interval is too far away, so set next lick position to 7000 samples = 7.0 sec')
								% 
								nextEvent2 = Xtrim1(end) + obj.GLM.pos.pos1-1 + 7000;							
							end
							% 
							% 	Get n points in end-cut-off ramp: (samples)
							% 
							n2 = nextEvent2 - (Xtrim1(end) + obj.GLM.pos.pos1-1);
						end
					end
					% 
					% 	Find the first delta timestamp to use with first cue event
					% 
					allEvent1Pos = obj.getXPositionsWRTgfit(preXtrim_s{1});
					minEvent1TrialNum = find(allEvent1Pos == Xtrim1(1) + obj.GLM.pos.pos1-1, 1, 'first');
					maxEvent2TrialNum = find(allEvent1Pos <= Xtrim2(end) + obj.GLM.pos.pos1-1, 1, 'last');
					% 
					% 	Trim delTimes
					% 
					delTimes_trim = delTimes(minEvent1TrialNum:maxEvent2TrialNum);
					% 
					% 	Convert delTimes_trim to samples
					% 
					delTimes_trim_samples = delTimes_trim*obj.Plot.samples_per_ms*1000;
					% 
					% 	Xtrim = {event1pos, event2pos, delTimes_trim_samples, n1, n2}, for use by the calling method
					%
					Xtrim = {Xtrim1, Xtrim2, delTimes_trim_samples, n1, n2}; 
				end


			elseif size(preXtrim_s, 2) == 3
				if strcmp(preXtrim_s{3}, 'movement')
					disp('	Trimming timestamps for timeseries event (like EMG)...')
					% 
					% 	Trim the timestamps of the movement event...
					% 
					% 	Format: preXtrim_s = {[signal], [times], 'movement'}
					% 
					ts_sm = obj.smooth(preXtrim_s{1}, obj.GLM.flush.smoothing*2);
					Xtrim = ts_sm(obj.GLM.pos.pos1*2:obj.GLM.pos.pos2*2);
					disp(['	Start times are: gfit:' num2str(obj.GLM.gtimes(obj.GLM.pos.pos1)), ' - ' num2str(obj.GLM.gtimes(obj.GLM.pos.pos2)), ' move: ' num2str(preXtrim_s{2}(2*obj.GLM.pos.pos1)), ' - ' num2str(preXtrim_s{2}(2*obj.GLM.pos.pos2))])
					if numel(Xtrim) ~= obj.GLM.flush.t*2
						warning('Xtrimmed movement signal not the right length. Adding one timepoint...')
						disp(['Now start times are: gfit:' num2str(obj.GLM.gtimes(obj.GLM.pos.pos1)), ' - ' num2str(obj.GLM.gtimes(obj.GLM.pos.pos2)), ' move: ' num2str(preXtrim_s{2}(2*obj.GLM.pos.pos1 - 1)), ' - ' num2str(preXtrim_s{2}(2*obj.GLM.pos.pos2))])
						Xtrim = ts_sm(obj.GLM.pos.pos1*2 - 1:obj.GLM.pos.pos2*2);
					end
				elseif numel(preXtrim_s{2}) == numel(preXtrim_s{3})
					disp('	Trimming timestamps for ssStretch events')
					%				
					% 	Get paired events. If no partner event, just delete the cue stamp ([])
					% 
					delTimes = nan(size(preXtrim_s{3}));
					valid_event1 = preXtrim_s{1}(preXtrim_s{3});
					event2 = preXtrim_s{2};
					delTimes = event2 - valid_event1;
					if isfield(obj.GLM.flush, 'idxcat')
						% 
						% 	Just convert to positions relative to the gfit times
						% 
						Xtrim1 = valid_event1;%round(valid_event1(1) * 1000) + 1;
						Xtrim1 = round(Xtrim1*obj.Plot.samples_per_ms*1000);
						Xtrim2 = event2;%round(event2(end) * 1000) - 1;
						Xtrim2 = round(Xtrim2*obj.Plot.samples_per_ms*1000);
						n1 = 0;
						n2 = 0;
						delTimes = delTimes*obj.Plot.samples_per_ms*1000;
						% 
						% 	Xtrim = {event1pos, event2pos, delTimes_trim_samples, n1, n2}, for use by the calling method
						%
						Xtrim = {Xtrim1, Xtrim2, delTimes, n1, n2};			
					else
						error('Not Implemented for unpaired timestamps!')
					end
				else
					error('Not Implemented - should this have been EMG/X/movement? we changed this on 3-25-19')
				end
			end
		end

		function Xtrim_pos = getXPositionsWRTgfit(obj, Xtrim_s)
		% 
		% 	find the position of each timestamp using obj.GLM.gtimes (gets you within 1 ms of actual time) 
		%     - the error in sampling rate over time is really small so we can just assume positions
		% 	ONLY USE THIS IN CONTEXT OF GLM - IF WE HAVE CHANGED FLUSH.T_TIMES I THINK IT SCREWS US UP! 3/16/19
		%   
            chk = dbstack;
            if ~strcmp(chk(2).name, 'CLASS_photometry_roadmapv1_4.nestedGLM') && ~strcmp(chk(2).name, 'CLASS_photometry_roadmapv1_4.build_a_trial2lick')
                if ~numel(chk) > 2 || ~strcmp(chk(3).name, 'CLASS_photometry_roadmapv1_4.simulateCTA')
                    disp('****DONT USE THIS METHOD AFTER USING nestedGLM, will go with trimmed dataset!!! NOTE TO FIX THIS!!!!!!!!!!!!!!!!')
                end
            end
			% 
			% 	Find starting position
			% 
            if isfield(obj.GLM, 'flush') && isfield(obj.GLM.flush, 't_times')
                gtimesStart = obj.GLM.flush.t_times(1);
            else
                obj.GLM.flush.t_times = obj.GLM.gtimes;
                gtimesStart = obj.GLM.flush.t_times(1);
            end
			% 
			%	Find the timeshift assuming 1ms is at position 1 
			% 
            if ~strcmpi(obj.iv.signaltype_, 'Camera')
    			shift = 1 - gtimesStart;
				% 
				% 	Check sampling rate
				% 
				%             warning('Noticed rounding error on samples_per_ms -- fixed 12/10/18. Unverified.')
				samples_per_ms = 1/(mode(obj.GLM.flush.t_times(2:end)-obj.GLM.flush.t_times(1:end-1))*1000);
				%             samples_per_ms = round((obj.GLM.flush.t_times(2)-obj.GLM.flush.t_times(1))*1000);
				% 
				% 	Convert Xtrim_s to positions
				% 
	            Xtrim_pos = round(1000*Xtrim_s*samples_per_ms + shift);
            else
            	% 
            	% 	Camera has inconsistent sampling rate so you have to match up each event one by one...
            	% 
                for itime = 1:numel(Xtrim_s)
                	posi = find(obj.GLM.gtimes > Xtrim_s(itime), 1, 'first');
                	Xtrim_pos(itime) = (posi-1)*(obj.GLM.gtimes(posi)-Xtrim_s(itime) > Xtrim_s(itime) - obj.GLM.gtimes(posi-1)) + (posi)*(obj.GLM.gtimes(posi)-Xtrim_s(itime) < Xtrim_s(itime) - obj.GLM.gtimes(posi-1));
            	end
            end
		end

		function addtdt(obj)
			% 
			% 	Allows user to add tdt gfit to the obj
			% 
			disp('	Select the tdt gfit datafile to use')		
			[xfile,xpath] = uigetfile('*.mat','Select the tdt gfit datafile to use');
			xStruct = load([xpath,xfile]);
			if isnumeric(xfile) && xfile == 0 && xpath == 0
				error('No set selected!')
			end				
			f = fieldnames(xStruct);
            fidx = 1;
            xStruct1 = getfield(xStruct, f{fidx});
            f = fieldnames(xStruct1);
            fidx = find(cellfun(@(x) contains(x,'gfit_signal'), f)>0);
            obj.GLM.tdt = getfield(xStruct1, f{fidx});

		end  


        function addX(obj, xRaw, xTimes)
			% 
			% 	Allows user to add a new X-dataset to the object
			% 

			if nargin < 3
				% 
				% 	Add/Overwrite existing xFit, xTimes using UI input
				% 
				disp('	Select the X datafile to use')
				xStruct = pullVarFromBaseWorkspace(obj, 'Select X structure');
				if isempty(xStruct)
					[xfile,xpath] = uigetfile('*.mat','Select the X datafile to use');
					xStruct = load([xpath,xfile]);
					if isnumeric(xfile) && xfile == 0 && xpath == 0
						warning('No X-datasets present. Selecting EMG instead.')
						obj.addEMG();
						return
					end
				end
				f = fieldnames(xStruct);
                fidx = find(cellfun(@(x) contains(x,'X'), f)>0);
                xStruct = getfield(xStruct, f{fidx});
				xRaw  = xStruct.values;
				xTimes  = xStruct.times;
			end
			%
            %	Get smoothed movement data
            %
            x_sm = gausssmooth(xRaw, 50, 'gauss');
            %
            %	Get low pass movement data - 1 sec
            %
            x_lp = gausssmooth(x_sm, 500, 'gauss');
            % 
            % 	Get high (band) pass movement data - 1 sec
            % 
            obj.GLM.xFit = gausssmooth(x_sm - x_lp, 50, 'gauss');
            obj.GLM.xTimes = xTimes;
		end  

		function addEMG(obj, emgRaw, emgTimes)
			% 
			% 	Allows user to add a new EMG-dataset to the object
			% 

			if nargin < 3
				% 
				% 	Add/Overwrite existing emgFit, emgTimes using UI input
				% 
				disp('	Select the EMG datafile to use')
				emgStruct = pullVarFromBaseWorkspace(obj, 'Select EMG structure');
				if isempty(emgStruct)
					[emgfile,emgpath] = uigetfile('*.mat','Select the day with EMG data to use');
					if isnumeric(emgfile) && emgfile == 0 && xpath == 0
						warning('No EMG-datasets present. Quitting movement data search. You can always add later manually with obj.addX() or obj.addEMG()')
						return
					end
					[emgfile,emgpath] = uigetfile('*.mat','Select the EMG datafile to use');
					emgStruct = load([emgpath,emgfile]);
				end
				f = fieldnames(emgStruct);
                fidx = find(cellfun(@(x) contains(x,'EMG'), f)>0);
                emgStruct = getfield(emgStruct, f{fidx});
				emgRaw  = emgStruct.values;
				emgTimes  = emgStruct.times;
			end
			%
            % %	Get smoothed movement data
            % %
            % emg_sm = gausssmooth(emgRaw, 50, 'gauss');
            % %
            % %	Get low pass movement data - 1 sec
            % %
            % emg_lp = gausssmooth(emg_sm, 500, 'gauss');
            % 
            % 	Get high (band) pass movement data - 1 sec
            % 
            obj.GLM.EMG = abs(emgRaw); %gausssmooth(emg_sm - emg_lp, 50, 'gauss');
            obj.GLM.EMGtimes = emgTimes;
		end  

		function V = pullVarFromBaseWorkspace(obj, prompt, Mode)
			% 
			% 	Pulls a variable out of the base workspace.
			% 		Mode = 'single' or 'multiple'
			% 
			if nargin < 3
				Mode = 'single';
			end
			if nargin < 2 || ~ischar(prompt)
				prompt = 'Select workspace variable';
			end
			str = evalin('base', 'who');
		
			[V,~] = listdlg('PromptString',prompt,...
				                'SelectionMode',Mode,...
				                'ListString',str);
			if ~isempty(V) && strcmp(Mode, 'single')
                V = str{V};
                V = evalin('base', V );
            elseif strcmp(Mode, 'multiple')
                V = arrayfun(@(x) evalin('base', str{x}), V, 'UniformOutput', 0);
            else
                return
            end
		end


		function getFirstLickCategory(obj, windows)
			% 
			% 	Calculates each category and adds the timestamps to the GLM array
			% 
			disp('	Getting first lick categories for GLM')
			if nargin < 2
				windows.rxn = 0.5;
				windows.early = 3.333;
				windows.reward = 7.0;
				warning('Using default windows for lick catgories -- Lick categories not defined for pavlovian training or NON-500ms days')
			end
			valid_cues = obj.GLM.cue_s(obj.GLM.fLick_trial_num);
			f_licks = obj.GLM.firstLick_s;
			delTimes = f_licks - valid_cues;

			obj.GLM.fLick_s.rxn = f_licks(delTimes <= windows.rxn);
			obj.GLM.fLick_s.early = f_licks(delTimes > windows.rxn & delTimes <= windows.early);
			obj.GLM.fLick_s.reward = f_licks(delTimes > windows.early & delTimes <= windows.reward);
			obj.GLM.fLick_s.iti = f_licks(delTimes > windows.reward);
		end


		function [a, t_times, t] = build_a_trial2lick(obj, smoothing)
			if isfield(obj.GLM, 'flush') && isfield(obj.GLM.flush, 'recycleUniformSn') && obj.GLM.flush.recycleUniformSn == true;
				% 
				% 	We want to reuse the trial selection from other nests, so we will not randomize and pick again. Instead, pass on to the end...
				%
				disp('****** REUSING PRIOR UNIFORM TRIAL SELECTION ******') 
				% 
				% 	Now, reset this value so that we don't use it again... must respecify each time
				% 
				obj.GLM.flush.recycleUniformSn = false;
			else
				debugOn = true;
				uniformOn = false;
				% 
				% 	Get rid of any trials longer than 7 sec...
				% 
				if ~isfield(obj.iv, 'correctedSamplingRate')
	                warning('Correcting Sampling Rate...')
	                obj.correctSamplingRate;
	            end
				samples_per_ms = obj.Plot.samples_per_ms; %round((obj.GLM.gtimes(2)-obj.GLM.gtimes(1))*1000);
				obj.GLM.pos.flick = obj.getXPositionsWRTgfit(obj.GLM.firstLick_s);
				% obj.GLM.pos.fLick = round(1000*obj.GLM.firstLick_s*samples_per_ms)+1;
	            if ~isfield(obj.GLM, 'cue')
	                obj.GLM.cue = obj.GLM.cue_s;
	            end
				obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue);
				% obj.GLM.pos.cue = round(1000*obj.GLM.cue_s*samples_per_ms) + 1;
				% 
				% 	All trials with a lick...
				% 
				trialpool = obj.GLM.fLick_trial_num;
				% 
				%	Get rid of any trials longer than 7 sec from consideration... 
				% 
				% warning('need to remove >7s licks later on - do this later. 11/15/18')	Looks good 11/15/18
				% This is problematic, try removing later
				% tooLongLicks = find(obj.GLM.pos.fLick - obj.GLM.pos.cue(trialpool) > 7000);
				% trialpool(ismember(trialpool,tooLongLicks)) = [];
				% 
				% 	Shuffle the trials in each set...
				% 
				obj.GLM.flush.shuffledfLickIdx = randperm(numel(trialpool));
				obj.GLM.flush.shuffledTrials = trialpool(obj.GLM.flush.shuffledfLickIdx);
				
				if ~debugOn
					obj.GLM.flush.trialsPerSet = floor(numel(trialpool)/2);
					% obj.GLM.flush.SnfLickIdx = obj.GLM.flush.shuffledfLickIdx(1:obj.GLM.flush.trialsPerSet);
					% obj.GLM.flush.SnTrials = obj.GLM.flush.shuffledTrials(1:obj.GLM.flush.trialsPerSet);
				else
					% warning('Debug turned on - we are not randomizing trials here, and using WHOLE dataset...')
					obj.GLM.flush.trialsPerSet = floor(numel(trialpool));
					% 
					% 	DEBUG!!!!!!!!!!!!!!!! no randomization...
					% 
					obj.GLM.flush.SnfLickIdx = 1:obj.GLM.flush.trialsPerSet;
					obj.GLM.flush.SnTrials = trialpool(1:obj.GLM.flush.trialsPerSet);
				end

				obj.GLM.pos.pos1 = 1;
				obj.GLM.pos.pos2 = numel(obj.GLM.gfit);
				obj.GLM.gfit_sm = obj.smooth(obj.GLM.gfit, smoothing);
				% 
				% 	If we are selecting a more uniform distribution of trial times, let's do that now:
				% 
				% disp('	NOT FITTING WITH 0-1s intervals!!!!!!')
				% binWindows = [0,1,2,3,4,5,6,7]; % previously [1,2,3,4,5,6,7]
				binWindows = [1,2,3,4,5,6,7]; % previously [0,1,2,3,4,5,6,7]
				if uniformOn
					disp('*** Selecting a more Uniform Set of trials ***')
					if isfield(obj.GLM, 'uniformTrialNums')
						obj.GLM.uniformTrialNums = [];
					end
					lick_tbt_trim_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrials), obj.GLM.pos.flick(obj.GLM.flush.SnfLickIdx), 'UniformOutput', 0)); 
					% lick_tbt_trim_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrials), obj.GLM.pos.fLick(obj.GLM.flush.SnfLickIdx), 'UniformOutput', 0)); 
					[N,edges] = histcounts(lick_tbt_trim_s,binWindows);
					if ~suppressPlot
						figure, subplot(1,2,1), histogram(lick_tbt_trim_s, binWindows), title('Distribution of Lick Times in Sn before Uniform operation')
					end
					% 
					% 	Ok, now that we have found number in each bin, let's go with the smallest bin and randomly select trials that fit in each category
					% 
					ntrialsToFit = min(N);
					disp(['		*** Fitting ' num2str(ntrialsToFit) ' trials from each 1s bin...'])
					nTrialsTotal = ntrialsToFit*(numel(edges)-1);
					obj.GLM.flush.SnTrialsUniform = nan(1, nTrialsTotal);
					obj.GLM.flush.SnfLickIdxUniform = nan(1, nTrialsTotal);
					for ibin = 1:numel(edges)-1
	% 							warning('DEBUG
	% 							HERE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
	% 							seems ok 11/15/18
						trialIdxs = find(lick_tbt_trim_s >= edges(ibin) & lick_tbt_trim_s < edges(ibin+1));
						idxsToKeep = randperm(numel(trialIdxs),ntrialsToFit);
	                    if edges(1) == 0
	                        obj.GLM.flush.SnTrialsUniform(1+edges(ibin)*ntrialsToFit:ntrialsToFit+edges(ibin)*ntrialsToFit) = obj.GLM.flush.SnTrials(trialIdxs(idxsToKeep));
	                        obj.GLM.flush.SnfLickIdxUniform(1+edges(ibin)*ntrialsToFit:ntrialsToFit+edges(ibin)*ntrialsToFit) = obj.GLM.flush.SnfLickIdx(trialIdxs(idxsToKeep));
	                    else
	                        if ibin == 1
	                            obj.GLM.flush.SnTrialsUniform(1:ntrialsToFit) = obj.GLM.flush.SnTrials(trialIdxs(idxsToKeep));
	                            obj.GLM.flush.SnfLickIdxUniform(1:ntrialsToFit) = obj.GLM.flush.SnfLickIdx(trialIdxs(idxsToKeep));
	                        else
	                            obj.GLM.flush.SnTrialsUniform(1+(ibin-1)*ntrialsToFit:ntrialsToFit+(ibin-1)*ntrialsToFit) = obj.GLM.flush.SnTrials(trialIdxs(idxsToKeep));
	                            obj.GLM.flush.SnfLickIdxUniform(1+(ibin-1)*ntrialsToFit:ntrialsToFit+(ibin-1)*ntrialsToFit) = obj.GLM.flush.SnfLickIdx(trialIdxs(idxsToKeep));
	                        end
	                    end
					end
					%
					[a,t,t_times, obj.GLM.flush.idx_b_t, obj.GLM.flush.idxcat, obj.Stat.GLM.aIdx] = obj.trial2lickTrim(obj.GLM.flush.SnTrialsUniform, obj.GLM.flush.SnfLickIdxUniform);
					lick_tbt_trim_uniform_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrialsUniform), obj.GLM.pos.flick(obj.GLM.flush.SnfLickIdxUniform), 'UniformOutput', 0)); 
					warning('RBF')
					obj.Stat.GLM.aIdx(1:end).time_s = lick_tbt_trim_uniform_s;
					% lick_tbt_trim_uniform_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrialsUniform), obj.GLM.pos.fLick(obj.GLM.flush.SnfLickIdxUniform), 'UniformOutput', 0)); 
					if ~suppressPlot
						subplot(1,2,2), histogram(lick_tbt_trim_uniform_s, binWindows), title('Distribution of Lick Times in Sn post Uniform operation')
					end
					% 
					% 	Keep # of trials per binwindow
					% 
					[obj.Stat.GLM.nTrialsPer1sCat,obj.GLM.flush.binEdges, obj.GLM.flush.SnBinIdx] = histcounts(lick_tbt_trim_uniform_s, binWindows)
					% 
					% 	Set the final values for ref:
					% 
					obj.GLM.flush.SnfLickIdx = obj.GLM.flush.SnfLickIdxUniform;
					obj.GLM.flush.SnTrials = obj.GLM.flush.SnTrialsUniform;
				else
					lick_tbt_trim_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(obj.GLM.flush.SnTrials), obj.GLM.pos.flick(obj.GLM.flush.SnfLickIdx), 'UniformOutput', 0)); 
					[N,edges,bins] = histcounts(lick_tbt_trim_s,binWindows);
					% 
					% 	Ok, now that we have found number in each bin, let's go with the smallest bin and randomly select trials that fit in each category
					% 
					nTrialsTotal = sum(N);
					disp(['		*** Fitting ' num2str(nTrialsTotal) ' trials total, NOT UNIFORM or RANDOM... but only up to ' num2str(max(edges)) 's'])
					obj.GLM.flush.SnTrials_sub7 = nan(nTrialsTotal,1);
					obj.GLM.flush.SnfLickIdx_sub7 = nan(nTrialsTotal,1);
					for ibin = 1:numel(edges)-1
						ntrialsToFit = N(ibin);
	                    trialIdxsInBin = find(bins == ibin);
						if ibin == 1
							obj.GLM.flush.SnTrials_sub7(1:N(ibin)) = obj.GLM.flush.SnTrials(trialIdxsInBin);
							obj.GLM.flush.SnfLickIdx_sub7(1:N(ibin)) = obj.GLM.flush.SnfLickIdx(trialIdxsInBin);
						else
							obj.GLM.flush.SnTrials_sub7(sum(N(1:ibin-1))+1:sum(N(1:ibin-1))+N(ibin)) = obj.GLM.flush.SnTrials(trialIdxsInBin);
							obj.GLM.flush.SnfLickIdx_sub7(sum(N(1:ibin-1))+1:sum(N(1:ibin-1))+N(ibin)) = obj.GLM.flush.SnfLickIdx(trialIdxsInBin);
						end
					end
					[a,t,t_times, obj.GLM.flush.idx_b_t, obj.GLM.flush.idxcat, obj.Stat.GLM.aIdx] = obj.trial2lickTrim(obj.GLM.flush.SnTrials_sub7, obj.GLM.flush.SnfLickIdx_sub7);
					for iTrial = 1:nTrialsTotal
                        obj.Stat.GLM.aIdx(iTrial).time_s = lick_tbt_trim_s(obj.GLM.flush.SnfLickIdx_sub7(iTrial));
                    end
					% 
					% 	Keep # of trials per binwindow
					% 
					[obj.Stat.GLM.nTrialsPer1sCat,obj.GLM.flush.binEdges, obj.GLM.flush.SnBinIdx] = histcounts(lick_tbt_trim_s, binWindows);
					% 
					% 	Set the final values for ref:
					% 
					obj.GLM.flush.SnfLickIdx = obj.GLM.flush.SnfLickIdx_sub7;
					obj.GLM.flush.SnTrials = obj.GLM.flush.SnTrials_sub7;
				end
				categoryEdges = [1, find([obj.Stat.GLM.aIdx(1:end-1).trialNum] > [obj.Stat.GLM.aIdx(2:end).trialNum])+1];
				for iTrial = 1:length(obj.Stat.GLM.aIdx)
					categ = find(iTrial>=categoryEdges, 1, 'last');
					obj.Stat.GLM.aIdx(iTrial).cat = categ;
				end
				
				obj.GLM.flush.a = a;
				obj.GLM.flush.t_times = t_times;
				obj.GLM.flush.t = t;
			end
		end


		function [a,t,t_times, idx_b_t, idxcat, aIdx] = trial2lickTrim(obj, trials, flickIdx)
			% 
			% 	Finds the positions within the trial window (lights-off up to the first lick) and concatenates the photometry data to make this a 1xt array
			% 
			% 	Added aIdx as output on 4/11/19 -- this is a matrix that tells us for each trial in a the following
			% 		aIdx = trial #	|	start pos in a 	| end pos in a 	|	trial time (s)	| 	category
			%--------------------------------------------------------------
			%
			% 	Find all the positions of lamp-off and first lick. If no first lick in first 7 sec, just leave that trial out, as it's ill-defined. 
			% 
			% obj.GLM.pos.lampOff;
			% 
			% 	Explicitly call all the samples between and add them to array of indicies for photometry
			% 
			% idx_b_t = arrayfun(@(lo, lick) lo:lick, obj.GLM.pos.lampOff(trials), obj.GLM.pos.fLick(flickIdx), 'UniformOutput', 0);
			idx_b_t = arrayfun(@(lo, lick) lo:lick, obj.GLM.pos.lampOff(trials), obj.GLM.pos.flick(flickIdx), 'UniformOutput', 0);
			idxcat = [];
			% 
			%	Form aIdx (used for xvalidation) 
			% 
			h.aIdx(numel(trials)).trialNum = [];
			h.aIdx(numel(trials)).startPos_a = [];
			h.aIdx(numel(trials)).endPos_a = [];
			h.aIdx(numel(trials)).time_s = [];
			total_a_length = 0;
			for idx = 1:numel(idx_b_t)
				h.aIdx(idx).trialNum = trials(idx);
			    idxcat = horzcat(idxcat, idx_b_t{idx, 1});
			    h.aIdx(idx).startPos_a = total_a_length + 1;
			    total_a_length = total_a_length + numel(idx_b_t{idx});
			    h.aIdx(idx).endPos_a = total_a_length;
			end
			% 
			% 	Collect variables
			% 
			a = obj.GLM.gfit_sm(idxcat);
			t = numel(idxcat);
			t_times = obj.GLM.gtimes(idxcat);
            aIdx = h.aIdx;
		end
			








		% -----------------------------------------------------
		% 				Combine stat objects
		%	Unverified 11/1/18
		% -----------------------------------------------------
		function obj3 = combineObj(obj, obj2, Mode, saveMode)
			if nargin < 4
				saveMode = 1;
			end
			if nargin < 3
				Mode = 'quickNdirty';
			end
			if ~isempty(obj.ChR2) && obj.Stim.stimobj
				warning('Method not verified for ChR2 data! 11/1/18')
				ChR2on = true;
			else
				ChR2on = false;
			end

			if iscell(obj2)
				Mode = 'list';
			end

			if strcmp(Mode, 'quickNdirty')
				error('Updates made when using list. be sure this method works...')
				disp('')
				disp('~~~~~~~~~~~~~~~~~~~~~~~ Combining Dataset Objects... ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
				disp('	Mode: quickNdirty --- just combine the bin averages. Won''t worry about carrying over anything from the second object.')
				disp('		-- Saves new object')
				disp('		-- Updates iv with the animals and files included')
				disp('		-- DOES weight the averages... but DON''T USE FOR STATS')
				disp('')
				% 
				% 	1. Make sure the objects are compatible
				% 
				if ~strcmp(obj.iv.setStyle,obj2.iv.setStyle)
					error('iv.setStyle not compatible')
				end
				if obj.iv.rxnwin_ ~= obj2.iv.rxnwin_
					error('iv.rxnwin_ not compatible')
				end
				if ~strcmp(obj.iv.signalname,obj2.iv.signalname)
					warning('signalname doesn''t match -- use caution')
				end
				if ~strcmp(obj.iv.gfit_win_,obj2.iv.gfit_win_)
					error('gfit windows not compatible')
				end
				if ~strcmp(obj.Mode,obj2.Mode) || ~strcmpi(obj.Mode,'times')
					error('Sets not processed in times mode')
				end
				if obj.BinParams.ogBins ~= obj2.BinParams.ogBins
					error('Sets not binned in the same way')
				end
				% 
				% 	Create empty new object
				% 	
				obj3 = CLASS_photometry_roadmapv1_4();
				% 
				% 	Copy over relevant properties from obj 1
				% 
				obj3.Plot = obj.Plot;
				obj3.iv = obj.iv;
				obj3.Mode = obj.Mode;
				obj3.BinParams = obj.BinParams;
				obj3.BinnedData = obj.BinnedData;
				% 
				% 	2. Update ivs
				% 
				obj3.iv.mousename_ = vertcat(obj.iv.mousename_, obj2.iv.mousename_);
                if length(obj.iv.files) == length(obj2.iv.files)
                    obj3.iv.files = vertcat(obj.iv.files, obj2.iv.files);
                elseif length(obj.iv.files) < length(obj2.iv.files)
                    obj3.iv.files = vertcat(obj.iv.files, obj2.iv.files(end-length(obj.iv.files)+1:end));
                else
                    obj3.iv.files = vertcat(obj.iv.files(end-length(obj2.iv.files)+1:end), obj2.iv.files);
                end
				obj3.iv.num_trials = obj.iv.num_trials + obj2.iv.num_trials;
				obj3.iv.num_si_ITI_licks = obj.iv.num_si_ITI_licks + obj2.iv.num_si_ITI_licks;
				obj3.iv.num_trials_category = horzcat(obj.iv.num_trials_category, obj2.iv.num_trials_category);
				obj3.iv.exclusions_struct =horzcat(obj.iv.exclusions_struct, obj2.iv.exclusions_struct);
				% 
				% 	3. Check that datasets aligned properly...
				% 
				obj3.BinnedData = {};

				CTA1 = obj.BinnedData.CTA;
				LTA1 = obj.BinnedData.LTA;
				CTAtoLick1 = obj.BinnedData.CTAtoLick;
				siITI1 = obj.BinnedData.siITI;


				CTA2 = obj2.BinnedData.CTA;
				LTA2 = obj2.BinnedData.LTA;
				CTAtoLick2 = obj2.BinnedData.CTAtoLick;
				siITI2 = obj2.BinnedData.siITI;

				if obj.Plot.first_post_cue_position ~= obj2.Plot.first_post_cue_position
					warning('Datasets not aligned in CTA axis, realigning set #2')
					pad = obj.Plot.first_post_cue_position - obj2.Plot.first_post_cue_position;
					if pad > 0
						padding = nan(1, pad);
						CTA2 = cellfun(@(x) horzcat(padding, x), CTA2, 'UniformOutput', 0);
						CTAtoLick2 = cellfun(@(x) horzcat(padding, x), CTAtoLick2, 'UniformOutput', 0);
					else
						padding = abs(pad);
						CTA2 = cellfun(@(x) horzcat(x(1, padding:end),nan(1, pad)), CTA2, 'UniformOutput', 0);
						CTAtoLick2 = cellfun(@(x) horzcat(x(1, padding:end), nan(1, pad)), CTAtoLick2, 'UniformOutput', 0);
					end
				end
				if obj.Plot.lick_zero_position ~= obj2.Plot.lick_zero_position
					warning('Datasets not aligned in LTA axis, realigning set #2')
					pad = obj.Plot.lick_zero_position - obj2.Plot.lick_zero_position;
					if pad > 0
						padding = nan(1, pad);
						LTA2.rxn = cellfun(@(x) horzcat(padding, x), LTA2.rxn, 'UniformOutput', 0);
						LTA2.early = cellfun(@(x) horzcat(padding, x), LTA2.early, 'UniformOutput', 0);
						LTA2.rew = cellfun(@(x) horzcat(padding, x), LTA2.rew, 'UniformOutput', 0);
						LTA2.ITI = cellfun(@(x) horzcat(padding, x), LTA2.ITI, 'UniformOutput', 0);
						LTA2.All = cellfun(@(x) horzcat(padding, x), LTA2.All, 'UniformOutput', 0);
					else
						padding = abs(pad);
						LTA2.rxn = cellfun(@(x) horzcat(x(1, padding:end),nan(1, pad)), LTA2.rxn, 'UniformOutput', 0);
						LTA2.early = cellfun(@(x) horzcat(x(1, padding:end),nan(1, pad)), LTA2.early, 'UniformOutput', 0);
						LTA2.rew = cellfun(@(x) horzcat(x(1, padding:end),nan(1, pad)), LTA2.rew, 'UniformOutput', 0);
						LTA2.ITI = cellfun(@(x) horzcat(x(1, padding:end),nan(1, pad)), LTA2.ITI, 'UniformOutput', 0);
						LTA2.All = cellfun(@(x) horzcat(x(1, padding:end),nan(1, pad)), LTA2.All, 'UniformOutput', 0);
					end
				end
				if obj.Plot.si_lick_zero_position ~= obj2.Plot.si_lick_zero_position
					warning('Datasets not aligned in siITI axis, realigning set #2')
					pad = obj.Plot.si_lick_zero_position - obj2.Plot.si_lick_zero_position;
					if pad > 0
						padding = nan(1, pad);
						siITI2 = cellfun(@(x) horzcat(padding, x), siITI2, 'UniformOutput', 0);
					else
						padding = abs(pad);
						siITI2 = cellfun(@(x) horzcat(x(1, padding:end),nan(1, pad)), siITI2, 'UniformOutput', 0);
					end
				end
				% 
				% 	Scale the binned data based on number of trials per bin...
				% 
                if ~isfield(obj.BinParams, 'ntrials_per_bin_CLTA')
                    for ibin = 1:obj.BinParams.nbins_CLTA
                        obj.BinParams.ntrials_per_bin_CLTA(ibin) = numel(obj.BinParams.trials_in_each_bin(ibin).CTA);
                        obj2.BinParams.ntrials_per_bin_CLTA(ibin) = numel(obj2.BinParams.trials_in_each_bin(ibin).CTA);
                    end
                    for ibin = 1:obj.BinParams.nbins_siITI
                        obj.BinParams.ntrials_per_bin_siITI(ibin) = numel(obj.BinParams.trials_in_each_bin(ibin).siITI);
                        obj2.BinParams.ntrials_per_bin_siITI(ibin) = numel(obj2.BinParams.trials_in_each_bin(ibin).siITI);
                    end
                end
                
				obj3.BinParams.ntrials_per_bin_CLTA = obj.BinParams.ntrials_per_bin_CLTA + obj2.BinParams.ntrials_per_bin_CLTA;
				obj3.BinParams.ntrials_per_bin_siITI = obj.BinParams.ntrials_per_bin_siITI + obj2.BinParams.ntrials_per_bin_siITI;

				CTA1 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA1, obj.BinParams.ntrials_per_bin_CLTA, obj2.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
				CTAtoLick1 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick1, obj.BinParams.ntrials_per_bin_CLTA, obj2.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
				siITI1 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, siITI1, obj.BinParams.ntrials_per_bin_siITI, obj2.BinParams.ntrials_per_bin_siITI, 'UniformOutput', 0);
				LTA1rxn = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.rxn}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA1early = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.early}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA1rew = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.rew}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA1ITI = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.ITI}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA1All = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.All}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);

				CTA2 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA2, obj.BinParams.ntrials_per_bin_CLTA, obj2.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
				CTAtoLick2 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick2, obj.BinParams.ntrials_per_bin_CLTA, obj2.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
				siITI2 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, siITI2, obj.BinParams.ntrials_per_bin_siITI, obj2.BinParams.ntrials_per_bin_siITI, 'UniformOutput', 0);
				LTA2rxn = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA2.rxn}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA2early = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA2.early}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA2rew = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA2.rew}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA2ITI = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA2.ITI}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				LTA2All = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA2.All}, num2cell(obj.BinParams.ntrials_per_bin_CLTA), num2cell(obj2.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
				

				% 
				% 	Weighted average of the binned data...
				% 
				obj3.BinnedData.CTA = cellfun(@(o1,o2) nansum([o1;o2], 1), CTA1, CTA2, 'UniformOutput', 0);
				obj3.BinnedData.CTAtoLick = cellfun(@(o1,o2) nansum([o1;o2], 1), CTAtoLick1, CTAtoLick2, 'UniformOutput', 0);

				for ibin = 1:obj.BinParams.nbins_CLTA
					obj3.BinnedData.LTA(ibin).rxn = nansum([LTA1rxn{ibin}; LTA2rxn{ibin}], 1);
					obj3.BinnedData.LTA(ibin).early = nansum([LTA1early{ibin}; LTA2early{ibin}], 1);
					obj3.BinnedData.LTA(ibin).rew = nansum([LTA1rew{ibin}; LTA2rew{ibin}], 1);
					obj3.BinnedData.LTA(ibin).ITI = nansum([LTA1ITI{ibin}; LTA2ITI{ibin}], 1);
					obj3.BinnedData.LTA(ibin).All = nansum([LTA1All{ibin}; LTA2All{ibin}], 1);
				end
				
				obj3.BinnedData.siITI = cellfun(@(o1,o2) nansum([o1;o2], 1), siITI1, siITI2, 'UniformOutput', 0);
				% 
				% 	Clear any variables we shouldn't use...
				% 
				obj3.GLM = {};
				obj3.BinParams.trials_in_each_bin = [];
				% 
				% 	Save the new stat object...
				% 

				if save.Mode
					timestamp_now = datestr(now,'mm_dd_yy__HH_MM_AM');
                    mousename = reshape(obj3.iv.mousename_', 1, []);
					savefilename = [mousename '_' obj3.iv.signalname '_statObj_' num2str(obj3.BinParams.ogBins) 'bins_' timestamp_now];
					save([savefilename, '.mat'], 'obj', '-v7.3');
					disp(['Saved initiated object to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat (' datestr(now,'HH:MM AM') ') \n\n'])
				end
			% 
			% 
			% 
			%	LIST MODE  [[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]
			% 
			% 
			% 
			% 			
			elseif strcmp(Mode, 'list')
				disp('')
				disp('~~~~~~~~~~~~~~~~~~~~~~~ Combining Dataset Objects... ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~')
				disp('	Mode: list (based on quickNdirty, but for multiple objs) --- just combine the bin averages. Won''t worry about carrying over anything from the second object.')
				disp('		-- Saves new object')
				disp('		-- Updates iv with the animals and files included')
				disp('		-- DOES weight the averages... but DON''T USE FOR STATS')
				disp('')
				% 
				% 	1. Make sure the objects are compatible
				% 
				for iObj = 1:numel(obj2)
					temp = obj2{iObj};
					if ~strcmp(obj.iv.setStyle,temp.iv.setStyle)
						error('iv.setStyle not compatible')
					end
					if obj.iv.rxnwin_ ~= temp.iv.rxnwin_
						error('iv.rxnwin_ not compatible')
					end
					if ~strcmp(obj.iv.signalname,temp.iv.signalname)
						warning('signalname doesn''t match -- check!')
					end
					if ~strcmp(obj.iv.gfit_win_,temp.iv.gfit_win_)
						error('gfit windows not compatible')
					end
					if ~strcmp(obj.Mode,temp.Mode) || strcmpi(obj.Mode,'trials')
						error('Sets not processed in times mode')
					end
					if ~strcmpi(obj.Mode, 'outcome') && (obj.BinParams.ogBins ~= temp.BinParams.ogBins)
						error('Sets not binned in the same way')
					end
					if obj.Stim.stimobj ~= temp.Stim.stimobj
						error('Trying to combine stim and no stim datasets')
					end
				end
				% 
				% 	Create empty new object
				% 	
				obj3 = CLASS_photometry_roadmapv1_4();
				% 
				% 	Copy over relevant properties from obj 1
				% 
				obj3.Plot = obj.Plot;
				obj3.iv = obj.iv;
				obj3.Mode = obj.Mode;
				obj3.BinParams = obj.BinParams;
				obj3.BinnedData = obj.BinnedData;
				% 
				% 	2. Update ivs for each obj2
				% 
				obj3.iv.mousename_ = obj.iv.mousename_;
% 				obj3.iv.files = obj.iv.files;
				obj3.iv.num_trials = obj.iv.num_trials;
				obj3.iv.num_si_ITI_licks = obj.iv.num_si_ITI_licks;
				obj3.iv.num_trials_category = obj.iv.num_trials_category;
				obj3.iv.exclusions_struct = obj.iv.exclusions_struct;

				if ~ChR2on
					CTA1 = obj.BinnedData.CTA;
					LTA1 = obj.BinnedData.LTA;
					CTAtoLick1 = obj.BinnedData.CTAtoLick;
					siITI1 = obj.BinnedData.siITI;
					if ~isfield(obj.BinParams, 'ntrials_per_bin_CLTA')
	                    for ibin = 1:obj.BinParams.nbins_CLTA
	                        obj3.BinParams.ntrials_per_bin_CLTA(ibin) = numel(obj.BinParams.trials_in_each_bin(ibin).CTA);
	                    end
	                    for ibin = 1:temp.BinParams.nbins_siITI
	            	        obj3.BinParams.ntrials_per_bin_siITI(ibin) = numel(obj.BinParams.trials_in_each_bin(ibin).siITI);
	                    end
                	end
				else
					CTA1s = obj.BinnedData.stim.CTA;
					CTA1us = obj.BinnedData.unstim.CTA;
					LTA1s = obj.BinnedData.stim.LTA;
					LTA1us = obj.BinnedData.unstim.LTA;
					CTAtoLick1s = obj.BinnedData.stim.CTAtoLick;
					CTAtoLick1us = obj.BinnedData.unstim.CTAtoLick;
					siITI1 = obj.BinnedData.siITI;
					if ~isfield(obj.BinParams.stim, 'ntrials_per_bin_CLTA')
	                    for ibin = 1:obj.BinParams.stim.nbins_CLTA
	                        obj3.BinParams.stim.ntrials_per_bin_CLTA(ibin) = numel(obj.BinParams.stim.trials_in_each_bin(ibin).stim);
	                    end
	                    for ibin = 1:obj.BinParams.unstim.nbins_CLTA
	                        obj3.BinParams.unstim.ntrials_per_bin_CLTA(ibin) = numel(obj.BinParams.unstim.trials_in_each_bin(ibin).unstim);
	                    end
	                    for ibin = 1:temp.BinParams.nbins_siITI
	            	        obj3.BinParams.stim.ntrials_per_bin_siITI(ibin) = numel(obj.BinParams.stim.trials_in_each_bin(ibin).siITI);
	                    end
	                    for ibin = 1:temp.BinParams.nbins_siITI
	            	        obj3.BinParams.unstim.ntrials_per_bin_siITI(ibin) = numel(obj.BinParams.unstim.trials_in_each_bin(ibin).siITI);
	                    end
                	end
				end

				

				for iObj = 1:numel(obj2)
					temp = obj2{iObj};
                    if size(obj3.iv.mousename_, 2) > size(temp.iv.mousename_, 2)
                        temp.iv.mousename_ = [temp.iv.mousename_, ' '];
                    elseif size(obj3.iv.mousename_, 2) < size(temp.iv.mousename_, 2)
                        temp.iv.mousename_ = temp.iv.mousename_(2:end);
                    end
					obj3.iv.mousename_ = vertcat(obj3.iv.mousename_, temp.iv.mousename_);
% 	                if length(obj3.iv.files) == length(temp.iv.files)
% 	                    obj3.iv.files = vertcat(obj3.iv.files, temp.iv.files);
% 	                elseif length(obj3.iv.files) < length(temp.iv.files)
% 	                    obj3.iv.files = vertcat(obj3.iv.files, temp.iv.files{1}(end-length(obj3.iv.files)+1:end));
% 	                else
% 	                    obj3.iv.files = vertcat(obj3.iv.files(end-length(temp.iv.files)+1:end), temp.iv.files);
% 	                end
					obj3.iv.num_trials = obj3.iv.num_trials + temp.iv.num_trials;
					obj3.iv.num_si_ITI_licks = obj3.iv.num_si_ITI_licks + temp.iv.num_si_ITI_licks;
					obj3.iv.num_trials_category = horzcat(obj3.iv.num_trials_category, temp.iv.num_trials_category);
					obj3.iv.exclusions_struct =horzcat(obj3.iv.exclusions_struct, temp.iv.exclusions_struct);
					% 
					% 	3. Check that datasets aligned properly...
					% 
					obj3.BinnedData = {};



					if ~ChR2on
						CTA2 = temp.BinnedData.CTA;
						LTA2 = temp.BinnedData.LTA;
						LTA2rxn = {temp.BinnedData.LTA.rxn};
						LTA2early = {temp.BinnedData.LTA.early};
						LTA2rew = {temp.BinnedData.LTA.rew};
						LTA2ITI = {temp.BinnedData.LTA.ITI};
						LTA2All = {temp.BinnedData.LTA.All};
						CTAtoLick2 = temp.BinnedData.CTAtoLick;
						siITI2 = temp.BinnedData.siITI;
					else
						CTA2s = temp.BinnedData.stim.CTA;
						CTA2us = temp.BinnedData.unstim.CTA;
						LTA2s = temp.BinnedData.stim.LTA;
						LTA2us = temp.BinnedData.unstim.LTA;
						LTA2rxns = {temp.BinnedData.stim.LTA.rxn};
						LTA2rxnus = {temp.BinnedData.unstim.LTA.rxn};
						LTA2earlys = {temp.BinnedData.stim.LTA.early};
						LTA2earlyus = {temp.BinnedData.unstim.LTA.early};
						LTA2rews = {temp.BinnedData.stim.LTA.rew};
						LTA2rewus = {temp.BinnedData.unstim.LTA.rew};
						LTA2ITIs = {temp.BinnedData.stim.LTA.ITI};
						LTA2ITIus = {temp.BinnedData.unstim.LTA.ITI};
						LTA2Alls = {temp.BinnedData.stim.LTA.All};
						LTA2Allus = {temp.BinnedData.unstim.LTA.All};
						CTAtoLick2s = temp.BinnedData.stim.CTAtoLick;
						CTAtoLick2us = temp.BinnedData.unstim.CTAtoLick;
						siITI2 = temp.BinnedData.siITI;
					end

					if obj3.Plot.first_post_cue_position ~= temp.Plot.first_post_cue_position
						warning('Datasets not aligned in CTA axis, realigning set #2')
						pad = obj3.Plot.first_post_cue_position - temp.Plot.first_post_cue_position;
						if pad > 0
							padding = nan(1, pad);
							if ~ChR2on
								CTA2 = cellfun(@(x) horzcat(padding, x), CTA2, 'UniformOutput', 0);
								CTAtoLick2 = cellfun(@(x) horzcat(padding, x), CTAtoLick2, 'UniformOutput', 0);
							else
								CTA2s = cellfun(@(x) horzcat(padding, x), CTA2s, 'UniformOutput', 0);
								CTA2us = cellfun(@(x) horzcat(padding, x), CTA2us, 'UniformOutput', 0);
								CTAtoLick2s = cellfun(@(x) horzcat(padding, x), CTAtoLick2s, 'UniformOutput', 0);
								CTAtoLick2us = cellfun(@(x) horzcat(padding, x), CTAtoLick2us, 'UniformOutput', 0);
							end
						else
							padding = abs(pad);
							if ~ChR2on
								CTA2 = cellfun(@(x) x(1, padding+1:end), CTA2, 'UniformOutput', 0);
								CTAtoLick2 = cellfun(@(x) x(1, padding+1:end), CTAtoLick2, 'UniformOutput', 0);
							else
								CTA2s = cellfun(@(x) x(1, padding+1:end), CTA2s, 'UniformOutput', 0);
								CTA2us = cellfun(@(x) x(1, padding+1:end), CTA2us, 'UniformOutput', 0);
								CTAtoLick2s = cellfun(@(x) x(1, padding+1:end), CTAtoLick2s, 'UniformOutput', 0);
								CTAtoLick2us = cellfun(@(x) x(1, padding+1:end), CTAtoLick2us, 'UniformOutput', 0);								
							end
                        end
                        if ~ChR2on
                            rightpad = length(CTA1{1}) - length(CTA2{1});
                        else
                            rightpad = length(CTA1s{1}) - length(CTA2s{1});
                        end
                        if rightpad > 0
							padding = nan(1, rightpad);
							if ~ChR2on
								CTA2 = cellfun(@(x) horzcat(x, padding), CTA2, 'UniformOutput', 0);
								CTAtoLick2 = cellfun(@(x) horzcat(x, padding), CTAtoLick2, 'UniformOutput', 0);
							else
								CTA2s = cellfun(@(x) horzcat(x, padding), CTA2s, 'UniformOutput', 0);
								CTA2us = cellfun(@(x) horzcat(x, padding), CTA2us, 'UniformOutput', 0);
								CTAtoLick2s = cellfun(@(x) horzcat(x, padding), CTAtoLick2s, 'UniformOutput', 0);
								CTAtoLick2us = cellfun(@(x) horzcat(x, padding), CTAtoLick2us, 'UniformOutput', 0);								
							end
						elseif rightpad < 0
							padding = abs(rightpad);
							if ~ChR2on
								CTA2 = cellfun(@(x) x(1, 1:end-padding), CTA2, 'UniformOutput', 0);
								CTAtoLick2 = cellfun(@(x) x(1, 1:end-padding), CTAtoLick2, 'UniformOutput', 0);
							else
								CTA2s = cellfun(@(x) x(1, 1:end-padding), CTA2s, 'UniformOutput', 0);
								CTAtoLick2s = cellfun(@(x) x(1, 1:end-padding), CTAtoLick2s, 'UniformOutput', 0);
								CTA2us = cellfun(@(x) x(1, 1:end-padding), CTA2us, 'UniformOutput', 0);
								CTAtoLick2us = cellfun(@(x) x(1, 1:end-padding), CTAtoLick2us, 'UniformOutput', 0);
							end
						end
					end
					if obj3.Plot.lick_zero_position ~= temp.Plot.lick_zero_position
						warning('Datasets not aligned in LTA axis, realigning set #2')
						pad = obj3.Plot.lick_zero_position - temp.Plot.lick_zero_position;
						if pad > 0
							padding = nan(1, pad);
							if ~ChR2on
								LTA2rxn = cellfun(@(x) horzcat(padding, x), {LTA2.rxn}, 'UniformOutput', 0);
								LTA2early = cellfun(@(x) horzcat(padding, x), {LTA2.early}, 'UniformOutput', 0);
								LTA2rew = cellfun(@(x) horzcat(padding, x), {LTA2.rew}, 'UniformOutput', 0);
								LTA2ITI = cellfun(@(x) horzcat(padding, x), {LTA2.ITI}, 'UniformOutput', 0);
								LTA2All = cellfun(@(x) horzcat(padding, x), {LTA2.All}, 'UniformOutput', 0);
							else
								LTA2rxns = cellfun(@(x) horzcat(padding, x), {LTA2.rxns}, 'UniformOutput', 0);
								LTA2earlys = cellfun(@(x) horzcat(padding, x), {LTA2.earlys}, 'UniformOutput', 0);
								LTA2rews = cellfun(@(x) horzcat(padding, x), {LTA2.rews}, 'UniformOutput', 0);
								LTA2ITIs = cellfun(@(x) horzcat(padding, x), {LTA2.ITIs}, 'UniformOutput', 0);
								LTA2Alls = cellfun(@(x) horzcat(padding, x), {LTA2.Alls}, 'UniformOutput', 0);
								LTA2rxnus = cellfun(@(x) horzcat(padding, x), {LTA2.rxnus}, 'UniformOutput', 0);
								LTA2earlyus = cellfun(@(x) horzcat(padding, x), {LTA2.earlyus}, 'UniformOutput', 0);
								LTA2rewus = cellfun(@(x) horzcat(padding, x), {LTA2.rewus}, 'UniformOutput', 0);
								LTA2ITIus = cellfun(@(x) horzcat(padding, x), {LTA2.ITIus}, 'UniformOutput', 0);
								LTA2Allus = cellfun(@(x) horzcat(padding, x), {LTA2.Allus}, 'UniformOutput', 0);
							end
						else
							padding = abs(pad);
							if ~ChR2on
								LTA2rxn = cellfun(@(x) x(1, padding+1:end), {LTA2.rxn}, 'UniformOutput', 0);
								LTA2early = cellfun(@(x) x(1, padding+1:end), {LTA2.early}, 'UniformOutput', 0);
								LTA2rew = cellfun(@(x) x(1, padding+1:end), {LTA2.rew}, 'UniformOutput', 0);
								LTA2ITI = cellfun(@(x) x(1, padding+1:end), {LTA2.ITI}, 'UniformOutput', 0);
								LTA2All = cellfun(@(x) x(1, padding+1:end), {LTA2.All}, 'UniformOutput', 0);
							else
								LTA2rxns = cellfun(@(x) x(1, padding+1:end), {LTA2s.rxn}, 'UniformOutput', 0);
								LTA2earlys = cellfun(@(x) x(1, padding+1:end), {LTA2s.early}, 'UniformOutput', 0);
								LTA2rews = cellfun(@(x) x(1, padding+1:end), {LTA2s.rew}, 'UniformOutput', 0);
								LTA2ITIs = cellfun(@(x) x(1, padding+1:end), {LTA2s.ITI}, 'UniformOutput', 0);
								LTA2Alls = cellfun(@(x) x(1, padding+1:end), {LTA2s.All}, 'UniformOutput', 0);
								LTA2rxnus = cellfun(@(x) x(1, padding+1:end), {LTA2us.rxn}, 'UniformOutput', 0);
								LTA2earlyus = cellfun(@(x) x(1, padding+1:end), {LTA2us.early}, 'UniformOutput', 0);	
								LTA2rewus = cellfun(@(x) x(1, padding+1:end), {LTA2us.rew}, 'UniformOutput', 0);
								LTA2ITIus = cellfun(@(x) x(1, padding+1:end), {LTA2us.ITI}, 'UniformOutput', 0);
								LTA2Allus = cellfun(@(x) x(1, padding+1:end), {LTA2us.All}, 'UniformOutput', 0);
							end
                        end
                        if ~ChR2on
                            rightpad = length(LTA1(1).rxn) - length(LTA2rxn{1});
                        else
                            rightpad = length(LTA1s(1).rxn) - length(LTA2rxns{1});
                        end
						if rightpad > 0
							padding = nan(1, rightpad);
							if ~ChR2on
								LTA2rxn = cellfun(@(x) horzcat(x, padding), LTA2rxn, 'UniformOutput', 0);
								LTA2early = cellfun(@(x) horzcat(x, padding), LTA2early, 'UniformOutput', 0);
								LTA2rew = cellfun(@(x) horzcat(x, padding), LTA2rew, 'UniformOutput', 0);
								LTA2ITI = cellfun(@(x) horzcat(x, padding), LTA2ITI, 'UniformOutput', 0);
								LTA2All = cellfun(@(x) horzcat(x, padding), LTA2All, 'UniformOutput', 0);
							else
								LTA2rxns = cellfun(@(x) horzcat(x, padding), LTA2rxns, 'UniformOutput', 0);
								LTA2earlys = cellfun(@(x) horzcat(x, padding), LTA2earlys, 'UniformOutput', 0);
								LTA2rews = cellfun(@(x) horzcat(x, padding), LTA2rews, 'UniformOutput', 0);
								LTA2ITIs = cellfun(@(x) horzcat(x, padding), LTA2ITIs, 'UniformOutput', 0);
								LTA2Alls = cellfun(@(x) horzcat(x, padding), LTA2Alls, 'UniformOutput', 0);
								LTA2rxnus = cellfun(@(x) horzcat(x, padding), LTA2rxnus, 'UniformOutput', 0);
								LTA2earlyus = cellfun(@(x) horzcat(x, padding), LTA2earlyus, 'UniformOutput', 0);
								LTA2rewus = cellfun(@(x) horzcat(x, padding), LTA2rewus, 'UniformOutput', 0);
								LTA2ITIus = cellfun(@(x) horzcat(x, padding), LTA2ITIus, 'UniformOutput', 0);
								LTA2Allus = cellfun(@(x) horzcat(x, padding), LTA2Allus, 'UniformOutput', 0);
							end
						elseif rightpad < 0
							padding = abs(rightpad);
							if ~ChR2on
								LTA2rxn = cellfun(@(x) x(1, 1:end-padding), LTA2rxn, 'UniformOutput', 0);
								LTA2early = cellfun(@(x) x(1, 1:end-padding), LTA2early, 'UniformOutput', 0);
								LTA2rew = cellfun(@(x) x(1, 1:end-padding), LTA2rew, 'UniformOutput', 0);
								LTA2ITI = cellfun(@(x) x(1, 1:end-padding), LTA2ITI, 'UniformOutput', 0);
								LTA2All = cellfun(@(x) x(1, 1:end-padding), LTA2All, 'UniformOutput', 0);
							else
								LTA2rxns = cellfun(@(x) x(1, 1:end-padding), LTA2rxns, 'UniformOutput', 0);
								LTA2earlys = cellfun(@(x) x(1, 1:end-padding), LTA2earlys, 'UniformOutput', 0);
								LTA2rews = cellfun(@(x) x(1, 1:end-padding), LTA2rews, 'UniformOutput', 0);
								LTA2ITIs = cellfun(@(x) x(1, 1:end-padding), LTA2ITIs, 'UniformOutput', 0);
								LTA2Alls = cellfun(@(x) x(1, 1:end-padding), LTA2Alls, 'UniformOutput', 0);
								LTA2rxnus = cellfun(@(x) x(1, 1:end-padding), LTA2rxnus, 'UniformOutput', 0);
								LTA2earlyus = cellfun(@(x) x(1, 1:end-padding), LTA2earlyus, 'UniformOutput', 0);
								LTA2rewus = cellfun(@(x) x(1, 1:end-padding), LTA2rewus, 'UniformOutput', 0);
								LTA2ITIus = cellfun(@(x) x(1, 1:end-padding), LTA2ITIus, 'UniformOutput', 0);
								LTA2Allus = cellfun(@(x) x(1, 1:end-padding), LTA2Allus, 'UniformOutput', 0);
							end
						end
					end
					if obj3.Plot.si_lick_zero_position ~= temp.Plot.si_lick_zero_position
						warning('Datasets not aligned in siITI axis, realigning set #2')
						pad = obj3.Plot.si_lick_zero_position - temp.Plot.si_lick_zero_position;
						if pad > 0
                            warning('siITI leftpad >0 not validated yet 11/2/18')
							padding = nan(1, pad);
							siITI2 = cellfun(@(x) horzcat(padding, x), siITI2, 'UniformOutput', 0);
						else
							padding = abs(pad);
							siITI2 = cellfun(@(x) x(1, padding+1:end), siITI2, 'UniformOutput', 0);
                        end
                    end
                    
                    if length(siITI1{1}) - length(siITI2{1})
                        rightpad = length(siITI1{1}) - length(siITI2{1});
						if rightpad > 0
							padding = nan(1, rightpad);
							siITI2 = cellfun(@(x) horzcat(x,padding), siITI2, 'UniformOutput', 0);
                        elseif rightpad <0
							padding = abs(rightpad);
							siITI2 = cellfun(@(x) x(1, 1:end-padding), siITI2, 'UniformOutput', 0);
						end
					end
					% 
					% 	Scale the binned data based on number of trials per bin...
					% 
	                if ~ChR2on && ~isfield(temp.BinParams, 'ntrials_per_bin_CLTA')
	                    for ibin = 1:temp.BinParams.nbins_CLTA
	                        temp.BinParams.ntrials_per_bin_CLTA(ibin) = numel(temp.BinParams.trials_in_each_bin(ibin).CTA);
	                    end
	                    for ibin = 1:temp.BinParams.nbins_siITI
	                        temp.BinParams.ntrials_per_bin_siITI(ibin) = numel(temp.BinParams.trials_in_each_bin(ibin).siITI);
	                    end
                    elseif ChR2on && ~isfield(temp.BinParams.stim, 'ntrials_per_bin_CLTA')
                    	for ibin = 1:temp.BinParams.stim.nbins_CLTA
	                        temp.BinParams.stim.ntrials_per_bin_CLTA(ibin) = numel(temp.BinParams.stim.trials_in_each_bin(ibin).stim);
	                    end
	                    for ibin = 1:temp.BinParams.unstim.nbins_CLTA
	                        temp.BinParams.unstim.ntrials_per_bin_CLTA(ibin) = numel(temp.BinParams.unstim.trials_in_each_bin(ibin).unstim);
	                    end
	                    for ibin = 1:temp.BinParams.nbins_siITI
	                        temp.BinParams.stim.ntrials_per_bin_siITI(ibin) = numel(temp.BinParams.stim.trials_in_each_bin(ibin).siITI);
	                    end
	                    for ibin = 1:temp.BinParams.nbins_siITI
	                        temp.BinParams.unstim.ntrials_per_bin_siITI(ibin) = numel(temp.BinParams.unstim.trials_in_each_bin(ibin).siITI);
	                    end
	                end
	                
	                if ~ChR2on
						obj3.BinParams.ntrials_per_bin_CLTA = obj3.BinParams.ntrials_per_bin_CLTA + temp.BinParams.ntrials_per_bin_CLTA;
						obj3.BinParams.ntrials_per_bin_siITI = obj3.BinParams.ntrials_per_bin_siITI + temp.BinParams.ntrials_per_bin_siITI;

						CTA1 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA1, obj3.BinParams.ntrials_per_bin_CLTA, temp.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						CTAtoLick1 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick1, obj3.BinParams.ntrials_per_bin_CLTA, temp.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						siITI1 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, siITI1, obj3.BinParams.ntrials_per_bin_siITI, temp.BinParams.ntrials_per_bin_siITI, 'UniformOutput', 0);
						LTA1rxn = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.rxn}, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1early = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.early}, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1rew = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.rew}, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1ITI = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.ITI}, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1All = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1.All}, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);

						CTA2 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA2, obj3.BinParams.ntrials_per_bin_CLTA, temp.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						CTAtoLick2 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick2, obj3.BinParams.ntrials_per_bin_CLTA, temp.BinParams.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						siITI2 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, siITI2, obj3.BinParams.ntrials_per_bin_siITI, temp.BinParams.ntrials_per_bin_siITI, 'UniformOutput', 0);
						LTA2rxn = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2rxn, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2early = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2early, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2rew = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2rew, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2ITI = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2ITI, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2All = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2All, num2cell(obj3.BinParams.ntrials_per_bin_CLTA), num2cell(temp.BinParams.ntrials_per_bin_CLTA), 'UniformOutput', 0);
					else
						obj3.BinParams.stim.ntrials_per_bin_CLTA = obj3.BinParams.stim.ntrials_per_bin_CLTA + temp.BinParams.stim.ntrials_per_bin_CLTA;
						obj3.BinParams.stim.ntrials_per_bin_siITI = obj3.BinParams.stim.ntrials_per_bin_siITI + temp.BinParams.stim.ntrials_per_bin_siITI;

						CTA1s = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA1s, obj3.BinParams.stim.ntrials_per_bin_CLTA, temp.BinParams.stim.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						CTAtoLick1s = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick1s, obj3.BinParams.stim.ntrials_per_bin_CLTA, temp.BinParams.stim.ntrials_per_bin_CLTA, 'UniformOutput', 0);	
						LTA1rxns = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1s.rxn}, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1earlys = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1s.early}, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1rews = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1s.rew}, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1ITIs = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1s.ITI}, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1Alls = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1s.All}, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);

						CTA2s = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA2s, obj3.BinParams.stim.ntrials_per_bin_CLTA, temp.BinParams.stim.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						CTAtoLick2s = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick2s, obj3.BinParams.stim.ntrials_per_bin_CLTA, temp.BinParams.stim.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						LTA2rxns = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2rxns, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2earlys = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2earlys, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2rews = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2rews, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2ITIs = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2ITIs, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2Alls = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2Alls, num2cell(obj3.BinParams.stim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.stim.ntrials_per_bin_CLTA), 'UniformOutput', 0);


						obj3.BinParams.unstim.ntrials_per_bin_CLTA = obj3.BinParams.unstim.ntrials_per_bin_CLTA + temp.BinParams.unstim.ntrials_per_bin_CLTA;
						obj3.BinParams.unstim.ntrials_per_bin_siITI = obj3.BinParams.unstim.ntrials_per_bin_siITI + temp.BinParams.unstim.ntrials_per_bin_siITI;
						
						CTA1us = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA1us, obj3.BinParams.unstim.ntrials_per_bin_CLTA, temp.BinParams.unstim.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						CTAtoLick1us = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick1us, obj3.BinParams.unstim.ntrials_per_bin_CLTA, temp.BinParams.unstim.ntrials_per_bin_CLTA, 'UniformOutput', 0);	
						LTA1rxnus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1us.rxn}, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1earlyus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1us.early}, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1rewus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1us.rew}, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1ITIus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1us.ITI}, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA1Allus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, {LTA1us.All}, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);

						CTA2us = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTA2us, obj3.BinParams.unstim.ntrials_per_bin_CLTA, temp.BinParams.unstim.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						CTAtoLick2us = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, CTAtoLick2us, obj3.BinParams.unstim.ntrials_per_bin_CLTA, temp.BinParams.unstim.ntrials_per_bin_CLTA, 'UniformOutput', 0);
						LTA2rxnus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2rxnus, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2earlyus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2earlyus, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2rewus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2rewus, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2ITIus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2ITIus, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);
						LTA2Allus = cellfun(@(x,n1,n2) (n1/(n1+n2)).*x, LTA2Allus, num2cell(obj3.BinParams.unstim.ntrials_per_bin_CLTA), num2cell(temp.BinParams.unstim.ntrials_per_bin_CLTA), 'UniformOutput', 0);


						temp.BinParams.ntrials_per_bin_siITI = temp.BinParams.stim.ntrials_per_bin_siITI + temp.BinParams.unstim.ntrials_per_bin_siITI;
						obj3.BinParams.ntrials_per_bin_siITI = obj3.BinParams.stim.ntrials_per_bin_siITI + obj3.BinParams.unstim.ntrials_per_bin_siITI;

						siITI1 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, siITI1, obj3.BinParams.ntrials_per_bin_siITI, temp.BinParams.ntrials_per_bin_siITI, 'UniformOutput', 0);
						siITI2 = arrayfun(@(x,n1,n2) (n1/(n1+n2)).*x{1,1}, siITI2, obj3.BinParams.ntrials_per_bin_siITI, temp.BinParams.ntrials_per_bin_siITI, 'UniformOutput', 0);
					end
					% 
					% 	Weighted average of the binned data...
					% 
					if ~ChR2on
						obj3.BinnedData.CTA = cellfun(@(o1,o2) nansum([o1;o2], 1), CTA1, CTA2, 'UniformOutput', 0);
						obj3.BinnedData.CTAtoLick = cellfun(@(o1,o2) nansum([o1;o2], 1), CTAtoLick1, CTAtoLick2, 'UniformOutput', 0);

						for ibin = 1:obj3.BinParams.nbins_CLTA
							obj3.BinnedData.LTA(ibin).rxn = nansum([LTA1rxn{ibin}; LTA2rxn{ibin}], 1);
							obj3.BinnedData.LTA(ibin).early = nansum([LTA1early{ibin}; LTA2early{ibin}], 1);
							obj3.BinnedData.LTA(ibin).rew = nansum([LTA1rew{ibin}; LTA2rew{ibin}], 1);
							obj3.BinnedData.LTA(ibin).ITI = nansum([LTA1ITI{ibin}; LTA2ITI{ibin}], 1);
							obj3.BinnedData.LTA(ibin).All = nansum([LTA1All{ibin}; LTA2All{ibin}], 1);
						end
					else
						obj3.BinnedData.stim.CTA = cellfun(@(o1,o2) nansum([o1;o2], 1), CTA1s, CTA2s, 'UniformOutput', 0);
						obj3.BinnedData.stim.CTAtoLick = cellfun(@(o1,o2) nansum([o1;o2], 1), CTAtoLick1s, CTAtoLick2s, 'UniformOutput', 0);

						obj3.BinnedData.unstim.CTA = cellfun(@(o1,o2) nansum([o1;o2], 1), CTA1us, CTA2us, 'UniformOutput', 0);
						obj3.BinnedData.unstim.CTAtoLick = cellfun(@(o1,o2) nansum([o1;o2], 1), CTAtoLick1us, CTAtoLick2us, 'UniformOutput', 0);

						for ibin = 1:obj3.BinParams.stim.nbins_CLTA
							obj3.BinnedData.stim.LTA(ibin).rxn = nansum([LTA1rxns{ibin}; LTA2rxns{ibin}], 1);
							obj3.BinnedData.stim.LTA(ibin).early = nansum([LTA1earlys{ibin}; LTA2earlys{ibin}], 1);
							obj3.BinnedData.stim.LTA(ibin).rew = nansum([LTA1rews{ibin}; LTA2rews{ibin}], 1);
							obj3.BinnedData.stim.LTA(ibin).ITI = nansum([LTA1ITIs{ibin}; LTA2ITIs{ibin}], 1);
							obj3.BinnedData.stim.LTA(ibin).All = nansum([LTA1Alls{ibin}; LTA2Alls{ibin}], 1);
						end
						for ibin = 1:obj3.BinParams.unstim.nbins_CLTA
							obj3.BinnedData.unstim.LTA(ibin).rxn = nansum([LTA1rxnus{ibin}; LTA2rxnus{ibin}], 1);
							obj3.BinnedData.unstim.LTA(ibin).early = nansum([LTA1earlyus{ibin}; LTA2earlyus{ibin}], 1);
							obj3.BinnedData.unstim.LTA(ibin).rew = nansum([LTA1rewus{ibin}; LTA2rewus{ibin}], 1);
							obj3.BinnedData.unstim.LTA(ibin).ITI = nansum([LTA1ITIus{ibin}; LTA2ITIus{ibin}], 1);
							obj3.BinnedData.unstim.LTA(ibin).All = nansum([LTA1Allus{ibin}; LTA2Allus{ibin}], 1);
						end
					end

					obj3.BinnedData.siITI = cellfun(@(o1,o2) nansum([o1;o2], 1), siITI1, siITI2, 'UniformOutput', 0);
					% 
					% 	Init for next round
					% 
					if ~ChR2on
						CTA1 = obj3.BinnedData.CTA;
						LTA1 = obj3.BinnedData.LTA;
						CTAtoLick1 = obj3.BinnedData.CTAtoLick;
						siITI1 = obj3.BinnedData.siITI; 
					else
						CTA1s = obj3.BinnedData.stim.CTA;
						CTA1us = obj3.BinnedData.unstim.CTA;
						LTA1s = obj3.BinnedData.stim.LTA;
						LTA1us = obj3.BinnedData.unstim.LTA;
						CTAtoLick1s = obj3.BinnedData.stim.CTAtoLick;
						CTAtoLick1us = obj3.BinnedData.unstim.CTAtoLick;
						siITI1 = obj3.BinnedData.siITI; 
					end
				end


				% 
				% 	Clear any variables we shouldn't use...
				% 
				obj3.GLM = {};
				obj3.BinParams.trials_in_each_bin = [];
				if ChR2on
					obj3.Stim.stimobj = 1;
				end
				% 
				% 	Save the new stat object...
				%
				if saveMode
					timestamp_now = datestr(now,'mm_dd_yy__HH_MM_AM');
                    mousename = reshape(obj3.iv.mousename_', 1, []);
					savefilename = [mousename '_' obj3.iv.signalname '_statObj_' num2str(obj3.BinParams.ogBins) 'bins_' timestamp_now];
					save([savefilename, '.mat'], 'obj3', '-v7.3');
					disp(['Saved initiated object to ' strjoin(strsplit(pwd, '\'), '/') savefilename '.mat (' datestr(now,'HH:MM AM') ') \n\n'])
				end



			end 	%/ end Mode
		end %/ end combineSets

		function objList = getCellListOfObj(obj, priorList)
			% 
			% 	
			% 
			if nargin < 2
				priorList = {};
			end
			objList = obj.pullVarFromBaseWorkspace(['Select objects from workspace to combine'], 'multiple');
				if isempty(objList)
					[file,path] = uigetfile('*.mat', 'Select objects from file to combine', 'MultiSelect', 'on');
					if ~iscell(file) & file == 0
						disp('No files selected, aborting...')
						return
					end
					if iscell(file)
						disp('loading files...')
						objStructList = cellfun(@(File) load([path, File]), file, 'UniformOutput', 0);
                        objList = cellfun(@(s, n) s.obj, objStructList, num2cell(1:numel(objStructList)), 'UniformOutput', 0);
					else
						disp('loading files...')
						objStructList = load([path, file]);
                        objList = objStructList.obj;
					end
				end
			objList = horzcat(priorList, objList);
		end


		function obj2 = rebinObj(obj, Mode, nbins)
			% 
			% 	We will take the existing object and bin more grossly. Note this won't work if we want more bins than the original, so don't allow this case!
			% 
			if nargin < 2
				Mode = 'outcome';
			end
			if nargin < 3
				nbins = 4;
			end

			if strcmpi(Mode, 'outcome')

			else
				error('Method Mode not defined!')
			end
		end


		function bandPassAcc(obj)
			passmode = true;
			if passmode
				% 
				% 	Applies the band-pass filter for accel data to all binned data
				% 
				obj.BinnedData.CTA = cellfun(@(ts) obj.bandPass(ts), obj.BinnedData.CTA, 'UniformOutput', 0);
				obj.BinnedData.CTAtoLick = cellfun(@(ts) obj.bandPass(ts), obj.BinnedData.CTAtoLick, 'UniformOutput', 0);
	            for ibin = 1:length({obj.BinnedData.LTA.rxn})
	                obj.BinnedData.LTA(ibin).rxn = obj.bandPass(obj.BinnedData.LTA(ibin).rxn);
	                obj.BinnedData.LTA(ibin).early = obj.bandPass(obj.BinnedData.LTA(ibin).early);
	                obj.BinnedData.LTA(ibin).rew = obj.bandPass(obj.BinnedData.LTA(ibin).rew);
	                obj.BinnedData.LTA(ibin).ITI = obj.bandPass(obj.BinnedData.LTA(ibin).ITI);
	                obj.BinnedData.LTA(ibin).All = obj.bandPass(obj.BinnedData.LTA(ibin).All);
	            end
				obj.BinnedData.siITI = cellfun(@(ts) obj.bandPass(ts), obj.BinnedData.siITI, 'UniformOutput', 0);
			end
		end

		function bp = bandPass(obj, ts)
			%
            %	Get smoothed movement data
            %
            x_sm = gausssmooth(ts, 50, 'gauss');
            %
            %	Get low pass movement data - 1 sec
            %
            x_lp = gausssmooth(x_sm, 500, 'gauss');
            % 
            % 	Get high (band) pass movement data - 1 sec
            % 
            bp = gausssmooth(x_sm - x_lp, 50, 'gauss');
		end

		function hp = hiPass(obj, ts)
            %
            %	Get low pass movement data - 2.5 sec
            %
            x_lp = gausssmooth(ts, 5000, 'gauss');
            % 
            % 	Get high pass movement data - 2.5 sec
            % 
            hp = ts-x_lp;
		end

		function ave = iterAve(obj, x, c, t)
			ave = c + 1/t * (x - c);
		end


		function [x_, compositeSimulatedCurves, individualFeatureCurves] = simulateCTA(obj, EventIdxs, Times, suppressPlot, overlay)
			Debug = true;
			% 
			if nargin < 2
				EventIdxs = 4;
			end 
			if nargin < 3 || isempty(Times)
				% Times = [500,1000,1500,2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000];
				Times = [7000,6500,6000,5500,5000,4500,4000,3500,3000,2500,2000,1500,1000];
%                 Times = [5000,4000,3000,2000,1000];
			end
			if nargin < 4
				suppressPlot = false;
			end
			if nargin < 5
				overlay{1} = false;
			end
			% 
			% 	Input which events you want to simulate, then plot them as a CTA
			%
			if ~overlay{1}
				f = figure;
                ax = subplot(1,1,1);
				C = linspecer(length(Times)); 
				hold(ax, 'on');
			else
				Debug = false;
				ax = overlay{2};
				C = linspecer(length(Times)); 
				if ~overlay{3} % overlay{3} indicates if this is the true data, and if so plots solid and thicker
					C(:, 4) = 1/overlay{4}; % overlay 4 is the nSim, so we want each plot to be worth 1 degree
				end
			end
			
			preCue = nan(1,1501);
            bC = obj.Stat.GLM.basisCurves; % there won't be any for time-dep features
            xb = obj.Stat.GLM.x_bars; % x_bars = 0 for time-dep features
            th = obj.Stat.GLM.th; 
			% 
			EventNames = obj.Stat.GLM.eventNames;
			% 
			%	|| DEBUG: Composite MOVEdelta feature plot 
			% 
			if ~suppressPlot
				dbFig = figure;
				axT = axes;
				axL = [];
				axL1 = [];
				maxC = 0;
				minC = 0;
				maxR = 0;
			end
			% 
			% 	For each event, get the shift over x-axis in array to align cue at 1501
			% 
			eventX = {};
			for iTimepoint = 1:numel(Times)
				timeCurves = {};
				% ftime = figure;
				% axtime = axes; 
				% hold(axtime, 'on');
				for iEvent = EventIdxs
					featIdxs = obj.Stat.GLM.eventMap(iEvent):obj.Stat.GLM.eventMap(iEvent+1)-1; % this tells us which theta go with this feature
					th_matched = th(featIdxs);
					if strcmp(EventNames(iEvent), 'cue')
						timeCurves{iEvent, 1} = horzcat(preCue, th_matched'*obj.Stat.GLM.basisXsingles{1, iEvent}, nan(1, Times(iTimepoint) - numel(th_matched'*obj.Stat.GLM.basisXsingles{1, iEvent})));
						% 
						% 	If too long, trim it
						% 
						if size(timeCurves{iEvent, 1},2) > numel(preCue) + Times(iTimepoint)
							timeCurves{iEvent, 1} = timeCurves{iEvent, 1}(1:numel(preCue) + Times(iTimepoint));
						end
					elseif strcmp(EventNames(iEvent), 'flick')
						timeCurves{iEvent, 1} = horzcat(preCue, nan(1, Times(iTimepoint)-500), th_matched'*obj.Stat.GLM.basisXsingles{1, iEvent});
						% 
						% 	If too long, trim it
						% 
						if size(timeCurves{iEvent, 1},2) > numel(preCue) + Times(iTimepoint)
							timeCurves{iEvent, 1} = timeCurves{iEvent, 1}(1:numel(preCue) + Times(iTimepoint));
						end
					elseif strcmp(EventNames(iEvent), 'timing-box')
						timeCurves{iEvent, 1} = th_matched .* Times(iTimepoint)/7000 .* ones(1, numel(preCue)+Times(iTimepoint));
					elseif strcmp(EventNames(iEvent), 'timing-ramp-conv')
						thIdx = 1;
		                thX = {};
		                n = Times(iTimepoint);
						for curve = 1:numel(bC{1, iEvent}) 
							x = [1:n]./n;
							% 
							% 	Must convolve the feature since these aren't deltas
							% 
							xCb = arrayfun(@(xshift) obj.convX_basisCos(x, bC{1,iEvent}{1,curve}, xshift, iEvent), xb{1, iEvent}{1, curve}, 'UniformOutput', 0);
			                % 
			                xCb_stack = reshape(xCb, [], 1);
		                    thX{curve, 1} = th_matched(thIdx:thIdx+size(xCb_stack)-1)'*cell2mat(xCb_stack);
		                    thIdx = thIdx+size(xCb_stack);
		                end
		                timeCurves{iEvent, 1} = horzcat(preCue, sum(cell2mat(thX),1));	
                    elseif strcmp(EventNames(iEvent), 'ramp-delta')
                        n = Times(iTimepoint);
                    	X = zeros(numel(th_matched), n);
                    	pos = [1:10:n];
                    	for ipos = 1:numel(pos)
                    		X(ipos, pos(ipos):pos(ipos)+10-1) = ones(1, 10);
                        end
                        if numel(pos) > numel(th_matched)
                            th_matched(end+(numel(pos) - numel(th_matched))) = 0;
                        end
						xCb_stack = th_matched'*X;
						timeCurves{iEvent, 1} = horzcat(preCue, xCb_stack, nan(1, Times(iTimepoint) - numel(xCb_stack)));
					elseif strcmp(EventNames(iEvent), 'ramp-delta-norm')
                        n = Times(iTimepoint);
                        if Debug
	                        disp('Using 10x downsample for ramp features')
                        end
                    	[X, ~] = obj.scaledHeatDesignMatrix([1:1:n], [1:10:n], true);
                    	if size(X, 1) < numel(th_matched)
                    		X(end:end+numel(th_matched)-size(X, 1), :) = 0;
                        elseif size(X, 1) > numel(th_matched)
                            th_matched(end:end+size(X, 1)-numel(th_matched)) = 0;
                    	end	
						xCb_stack = th_matched'*X;
						timeCurves{iEvent, 1} = horzcat(preCue, xCb_stack, nan(1, Times(iTimepoint) - numel(xCb_stack)));	
					elseif strcmp(EventNames(iEvent), 'stretch-time')
                        n = Times(iTimepoint);
                    	[X] = obj.stretchedTimeDesignMatrix([1:1:n], true);
                    	if size(X, 1) < numel(th_matched)
                    		X(end:end+numel(th_matched)-size(X, 1), :) = 0;
                        elseif size(X, 1) > numel(th_matched)
                            th_matched(end:end+size(X, 1)-numel(th_matched)) = 0;
                    	end	
						xCb_stack = th_matched'*X;
						timeCurves{iEvent, 1} = horzcat(preCue, xCb_stack, nan(1, Times(iTimepoint) - numel(xCb_stack)));	
					elseif strcmp(EventNames(iEvent), 'MOVEdelta')
						% 
						% 	For this simulation, we need to essentially put together some idea of when the MOVEdelta spikes happen
						% 		This is a little contrived, because we are simulating bins.
						% 		However, I suppose we could take the CLTA of the trials that would fit in this bin and pop the 
						% 			simulated movement data in
						% 
						% 	For each trial in the datasetput the first 500ms after the cue in left bin
						% 		then put aligned to flick all the spikes to the right bin
						% 		can do this as a moving sum of spikes (like a histogram), then convolve this with the MOVE kernel
						% 	Then, finally divide by the number of trials to get an average
						% 	
						% 	Also, need a third bin for pre-cue
						% 
						% 	We don't have to only use spike times that went into the model fit (which are hard to extract now)
						% 		Instead, use all EMG spike times that fit STDmultiplier thresholded data.
						% 		****** WE COULD DO THIS LATER WITH THE TRIAL INDICIES USED IN MODEL...
						% 
						if ~strcmp(obj.iv.signaltype_, 'photometry')
							error('Not implemented for control data. Check this before running')
						else
							spmsMultiplier = 2;
						end
						

						preCueBin = zeros(1501,1);
						ctaBin = zeros(500,1);
						ltaBin = zeros(Times(iTimepoint)-500,1);
						
						[trimMOVE, trimIdxs_choptime, trimIdxs_originaltime] = obj.trimTSbyLOItoLick(obj.GLM.MOVE, spmsMultiplier*obj.Plot.samples_per_ms); % note: this is for photometry signal object
						aboveTMOVEtrim = find(trimMOVE(2:end) > obj.Stat.GLM.STDmultiplier*std(trimMOVE)); % these stamps are in trim-samples. So take the trimIdxs_choptime(aboveTEMGtrim) to get real time gfit indicies

						realtimeGfitIdxs = trimIdxs_choptime(aboveTMOVEtrim);
						% realtimeMOVEIdxs = trimIdxs_originaltime(aboveTMOVEtrim);
						% 
						% 	Now find the position each of these spikes is nearest to - the next lick or the 
						% 

						trialsIncluded = obj.GLM.fLick_trial_num;
						flick_Idx = 1:numel(obj.GLM.firstLick_s);

						all_fl_wrtc_samples = zeros(numel(obj.GLM.lampOff_s), 1);
						all_fl_wrtc_samples(trialsIncluded) = obj.GLM.pos.fLick(flick_Idx) - obj.GLM.pos.cue(trialsIncluded);
                        all_fl_wrtts_samples = zeros(numel(obj.GLM.lampOff_s), 1);
                        all_fl_wrtts_samples(trialsIncluded) = obj.GLM.pos.fLick(flick_Idx);
						%debug:
						trialsInRange = [];
						eventsInRange = 0;
						nEventsCutOffByCLTA{iTimepoint} = 0;

						for iMoveStamp = 1:numel(realtimeGfitIdxs)
							% 
							% 	Find the associated LampOff:
							% 
							iTrial = find(obj.GLM.pos.lampOff <= realtimeGfitIdxs(iMoveStamp), 1, 'last');
							% 
							% 	Check the trial time and see if it seventsInRangehould go in this bin...
							% 
							if ~ismember(iTrial,obj.GLM.fLick_trial_num)
								break % go to outer loop
							end
							iTrialDuration_samples = all_fl_wrtc_samples(iTrial);
							if iTimepoint == 1
								inRange = iTrialDuration_samples >= Times(iTimepoint) && iTrialDuration_samples < 7500;
							else
							 	inRange = iTrialDuration_samples < Times(iTimepoint - 1) && iTrialDuration_samples >= Times(iTimepoint);
                            end
                            %
						 	if inRange 
						 		if ~ismember(iTrial, trialsInRange)
									trialsInRange(end+1) = iTrial;
								end
						 		eventsInRange = eventsInRange + 1;
								cDist = realtimeGfitIdxs(iMoveStamp) - obj.GLM.pos.cue(iTrial);
								if cDist <= 0
									% 
									% 	spike is before cue. So put in left-most bin
									% 
									preCueBin(1501+cDist,1) = preCueBin(1501+cDist,1) + 1;
								else
									if cDist <= 500
										% 
										% 	spike goes in cta bin
										% 
										ctaBin(cDist,1) = ctaBin(cDist,1) + 1;
									else
										% 
										% 	spike goes in lta bin
										% 
										lDist = all_fl_wrtts_samples(iTrial) - realtimeGfitIdxs(iMoveStamp); % if zero, goes right at the lick. so just do LTA width - stamp + 1
										if numel(ltaBin) > lDist
											ltaBin(end - lDist, 1) = ltaBin(end - lDist, 1) + 1;
										else
											nEventsCutOffByCLTA{iTimepoint} = nEventsCutOffByCLTA{iTimepoint} + 1; 
										end
									end
                                end
							end

						end
						% debug:
						if Debug
							disp(['DEBUG:   Trials in range for bin: ' num2str(Times(iTimepoint)), ' = ' num2str(numel(trialsInRange))])
							disp(['DEBUG:   Events in range: ' num2str(eventsInRange)])
							disp(['DEBUG:   # MOVEdelta events trimmed off by CLTA (ie, between cue and lick): ' num2str(nEventsCutOffByCLTA{iTimepoint})])
						end
						% 
						% 	Concatenate
						% 
						fullHxg = [preCueBin', ctaBin', ltaBin'];
                        if isempty(find(fullHxg>0, 1))
                            timeCurves{iEvent, 1} = fullHxg;
                        else
							% 
							% 	Now, convolve this with MOVE kernels...
							% 
							x_bars = obj.Stat.GLM.x_bars;
							kernelSig = fullHxg;
	                        basisCurves = obj.Stat.GLM.basisCurves;
							% 
							X = nan(numel(th_matched), numel(fullHxg));
	                        d_idx = 1;
							for curve = 1:numel(basisCurves{1, iEvent})  
								if Debug
			                        disp(['         Event #', EventNames{iEvent}, ' Curve #' num2str(curve), '...' datestr(now)])
		                        end
		                        xCb = arrayfun(@(xshift) obj.convX_basisCos(kernelSig, basisCurves{1,iEvent}{1,curve}, xshift, iEvent), x_bars{1, iEvent}{1, curve}, 'UniformOutput', 0);                            
		                        xCb_stack = reshape(xCb, [], 1);
	                            X(d_idx:d_idx-1+numel(xCb_stack), :) = cell2mat(xCb_stack);
	                            d_idx = d_idx+numel(xCb_stack);
		                    end
		                    % 
		                    % 	Composite feature for this timebin
		                    % 
							timeCurves{iEvent, 1} = th_matched'*X;
							% 
							% 	Divide by number of trials that went into this bin for the fair average
							% 
							timeCurves{iEvent, 1} = timeCurves{iEvent, 1}./numel(trialsInRange);
							% 
							% 	For debugging: Plot the raster of MOVEdelta events with cue and lick alignment and show the composite feature
							% 
							% row 1: the raster
							if ~suppressPlot
								xticks = ((1:numel(fullHxg)) - 1500)/1000;
								subplot(axT)
								axT = subplot(2, numel(Times), numel(Times) - iTimepoint + 1);
								axL1(end+1) = axT;
								if max(fullHxg) > maxR
									maxR = max(fullHxg);
								end
								bar(xticks, fullHxg), hold on
								plot(axT,[0,0], [0, maxR], 'r-')
								plot(axT,[Times(iTimepoint)/1000,Times(iTimepoint)/1000], [0, maxR], 'r-')
								title(axT,{num2str(Times(iTimepoint)/1000), ['ntrim: ', num2str(nEventsCutOffByCLTA{iTimepoint})]})
								linkaxes(axL1, 'xy');
		                        xlim(gca, [-1.5, 7]);
								% row 2: the composite feature
								axT = subplot(2, numel(Times), 2*numel(Times)-iTimepoint + 1);
								axL(end+1) = axT;
								if max(timeCurves{iEvent, 1}) > maxC
									maxC = max(timeCurves{iEvent, 1});
								end
								if min(max(timeCurves{iEvent, 1})) < minC
									minC = min(timeCurves{iEvent, 1});
								end
								plot(axT, xticks, timeCurves{iEvent, 1}), hold on
								plot(axT, [0,0], [minC, maxC], 'r-')
								plot(axT, [Times(iTimepoint)/1000,Times(iTimepoint)/1000], [minC, maxC], 'r-')
								title(axT, {'nEvents: ', [num2str(eventsInRange) '-' , num2str(nEventsCutOffByCLTA{iTimepoint})], ['nTrials: ' num2str(numel(trialsInRange))], []})
								xlabel(axT, 'time wrt cue (s)')
		                        linkaxes(axL, 'xy');
		                        xlim(gca, [-1.5, 7]);
	                        end
                        end

                    elseif strcmp(EventNames(iEvent), 'tdt')
						% 
						% 	For this simulation, we need to essentially create a CLTA for the 
						% 	trials that fit the binning, as if this were a real signal
						% 
						% 	The easiest way seems to be to treat this as a getBinnedTimeseries situation
						% 
						% 	Then, we will scale things based on the theta for the tdt signal 
						% 	(keeping in mind the fit was normalized already!)
						% 
						% 	We need to keep some info around to do this, namely how we scaled the tdt signal overall
						% 		this will be stored in the Stat field = obj.Stat.GLM.tsScalingFactor(iEvent)
						% 
						% 	getBinnedts of: th.* (obj.GLM.tdt ./ obj.Stat.GLM.tsScalingFactor(iEvent))
						% 
						if max(Times) ~= Times(end)
							binEdges = [fliplr(Times), max(Times)+mean(abs(Times(2:end)-Times(1:end-1)))];
							iBinIdx = numel(binEdges) - iTimepoint;
						else
							binEdges = [Times, max(Times)+mean(abs(Times(2:end)-Times(1:end-1)))];
							iBinIdx = iTimepoint;
						end
                        if iTimepoint == 1
							modeltdt = th_matched .* obj.smooth(obj.GLM.tdt) ./ obj.Stat.GLM.tsScalingFactor(iEvent);
							
							obj.getBinnedTimeseries(modeltdt, 'custom', binEdges, 20000, [], [], false);

							BinnedData.CTA = obj.ts.BinnedData.CTA;
							BinnedData.LTA = obj.ts.BinnedData.LTA;
							BinParams = obj.ts.BinParams;
							xticks.CTA = obj.ts.Plot.CTA.xticks.s;
							xticks.LTA = obj.ts.Plot.LTA.xticks.s;
							lick_zero_pos = find(obj.ts.Plot.LTA.xticks.s == 0);
							cue_1_pos = find(obj.ts.Plot.CTA.xticks.s == 0);

							CTA_start_pos = cue_1_pos-1500 + 2;
							tailMultiplier = 1;
	                        tick = 1/1000;
							CTA_cutoff_s = 0 + 0.5;
							CTA_cutoff_pos = cue_1_pos + 500; 
							LTA_trim_post_cue_pos = 500;
							LTA_trim_post_cue_s = 0.5;
							tail = 0;
							centerORmin = 'min';
	                        if strcmpi(centerORmin, 'min')
	                            binMinPos_LTA = cellfun(@(x) find(xticks.LTA > -(x), 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
	                            binMaxPos_CTA = cellfun(@(x) find(xticks.CTA > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
	                        elseif strcmpi(centerORmin, 'center')
	                            binMinPos_LTA = cellfun(@(x) find(xticks.LTA > -(x), 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
	                            binMaxPos_CTA = cellfun(@(x) find(xticks.CTA > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
	                        end	                        
                        	CTA_s1 = LTA_trim_post_cue_s;
                        	LTA_pos2 = lick_zero_pos+1;
                        end
	            		% 
	            		% 	For each bin...
	            		% 
	            		CTA_s2 = xticks.CTA(binMaxPos_CTA{iBinIdx});
	            		LTA_pos1 = binMinPos_LTA{iBinIdx} + LTA_trim_post_cue_pos;
	            		
	                    if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
	                        pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
	                        if pad > 0
	                            LTA_pos2 = LTA_pos2 + pad;
	                        else
	                            LTA_pos1 = LTA_pos1 - pad;
	                        end
	                    end
	            		if LTA_pos2 - LTA_pos1 >0
			            	LTA = BinnedData.LTA{1, iBinIdx}(LTA_pos1:LTA_pos2+tail*tailMultiplier);
						end
						CTA = BinnedData.CTA{1, iBinIdx}(CTA_start_pos:CTA_cutoff_pos);
						timeCurves{iEvent, 1} = [CTA, LTA];
					elseif strcmp(EventNames(iEvent), 'self') 
						% 
						% 	For this simulation, we need to essentially create a CLTA for the 
						% 	trials that fit the binning, as if this were a real signal
						% 
						% 	The easiest way seems to be to treat this as a getBinnedTimeseries situation
						% 
						% 	Then, we will scale things based on the theta for the tdt signal 
						% 	(keeping in mind the fit was normalized already!)
						% 
						% 	We need to keep some info around to do this, namely how we scaled the tdt signal overall
						% 		this will be stored in the Stat field = obj.Stat.GLM.tsScalingFactor(iEvent)
						% 
						% 	getBinnedts of: th.* (obj.GLM.tdt ./ obj.Stat.GLM.tsScalingFactor(iEvent))
						% 
						if max(Times) ~= Times(end)
							binEdges = [fliplr(Times), max(Times)+mean(abs(Times(2:end)-Times(1:end-1)))];
							iBinIdx = numel(binEdges) - iTimepoint;
						else
							binEdges = [Times, max(Times)+mean(abs(Times(2:end)-Times(1:end-1)))];
							iBinIdx = iTimepoint;
						end
                        if iTimepoint == 1
							modeltdt = th_matched .* obj.smooth(obj.GLM.gfit) ./ obj.Stat.GLM.tsScalingFactor(iEvent);
							obj.getBinnedTimeseries(modeltdt, 'custom', binEdges, 20000, [], [], false);

							BinnedData.CTA = obj.ts.BinnedData.CTA;
							BinnedData.LTA = obj.ts.BinnedData.LTA;
							BinParams = obj.ts.BinParams;
							xticks.CTA = obj.ts.Plot.CTA.xticks.s;
							xticks.LTA = obj.ts.Plot.LTA.xticks.s;
							lick_zero_pos = find(obj.ts.Plot.LTA.xticks.s == 0);
							cue_1_pos = find(obj.ts.Plot.CTA.xticks.s == 0);

							CTA_start_pos = cue_1_pos-1500 + 2;
							tailMultiplier = 1;
	                        tick = 1/1000;
							CTA_cutoff_s = 0 + 0.5;
							CTA_cutoff_pos = cue_1_pos + 500; 
							LTA_trim_post_cue_pos = 500;
							LTA_trim_post_cue_s = 0.5;
							tail = 0;
							centerORmin = 'min';
	                        if strcmpi(centerORmin, 'min')
	                            binMinPos_LTA = cellfun(@(x) find(xticks.LTA > -(x), 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
	                            binMaxPos_CTA = cellfun(@(x) find(xticks.CTA > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Min}, 'UniformOutput', false);
	                        elseif strcmpi(centerORmin, 'center')
	                            binMinPos_LTA = cellfun(@(x) find(xticks.LTA > -(x), 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
	                            binMaxPos_CTA = cellfun(@(x) find(xticks.CTA > x, 1, 'first'), {BinParams.s(1:BinParams.nbins_CLTA).CLTA_Center}, 'UniformOutput', false);
	                        end	                        
                        	CTA_s1 = LTA_trim_post_cue_s;
                        	LTA_pos2 = lick_zero_pos+1;
                        end
	            		% 
	            		% 	For each bin...
	            		% 
	            		CTA_s2 = xticks.CTA(binMaxPos_CTA{iBinIdx});
	            		LTA_pos1 = binMinPos_LTA{iBinIdx} + LTA_trim_post_cue_pos;
	            		
	                    if size(CTA_s1:tick:CTA_s2, 2) ~= size(LTA_pos1:LTA_pos2, 2)
	                        pad = size(CTA_s1:tick:CTA_s2, 2) - size(LTA_pos1:LTA_pos2, 2);
	                        if pad > 0
	                            LTA_pos2 = LTA_pos2 + pad;
	                        else
	                            LTA_pos1 = LTA_pos1 - pad;
	                        end
	                    end
	            		if LTA_pos2 - LTA_pos1 >0
			            	LTA = BinnedData.LTA{1, iBinIdx}(LTA_pos1:LTA_pos2+tail*tailMultiplier);
						end
						CTA = BinnedData.CTA{1, iBinIdx}(CTA_start_pos:CTA_cutoff_pos);
						timeCurves{iEvent, 1} = [CTA, LTA];
                    end
                    % 
	                %	The final feature is always th0 
	                % 
	                if numel(obj.Stat.GLM.th) == obj.Stat.GLM.eventMap(end)
% 	                	disp('th0 in use')
	                	timeCurves{end+1, 1} = th(end).*ones(size(timeCurves{iEvent, 1}));
	            	else
	            		error('Not implemented! Check that you have th0 and that eventMap is correct');
	        		end
                end
                % 
                % 	Make composite feature
                % 
                x_{iTimepoint} = -(numel(preCue)-1):Times(iTimepoint);
                minFeatSize = min(cell2mat(cellfun(@(e) numel(e), timeCurves, 'UniformOutput', 0)));
                timeCurves = cellfun(@(c) c(1:minFeatSize), timeCurves, 'UniformOutput', 0);
            	compositeSimulatedCurves{iTimepoint} = nansum(cell2mat(timeCurves), 1);
                if numel(x_{iTimepoint}) == numel(compositeSimulatedCurves)
                	if overlay{1} && overlay{3}
                		plot(ax, x_{iTimepoint}, compositeSimulatedCurves{iTimepoint}, 'color', C(iTimepoint, :), 'DisplayName', num2str(Times(iTimepoint)))
                    else
                    	plot(ax, x_{iTimepoint}, compositeSimulatedCurves{iTimepoint}, 'color', C(iTimepoint, :), 'DisplayName', num2str(Times(iTimepoint)))
                	end
                else
            		% 
            		% 	Make sure all the timeCurves are the same length
            		% 
                    if overlay{1} && overlay{3}
                    	plot(ax, x_{iTimepoint}(1:numel(compositeSimulatedCurves{iTimepoint})), compositeSimulatedCurves{iTimepoint}, 'color', C(iTimepoint, :), 'DisplayName', num2str(Times(iTimepoint)))
                	else
                		plot(ax, x_{iTimepoint}(1:numel(compositeSimulatedCurves{iTimepoint})), compositeSimulatedCurves{iTimepoint}, 'color', C(iTimepoint, :), 'DisplayName', num2str(Times(iTimepoint)))
            		end
                end

            end	
            if ~overlay{1}
	            legend(ax, 'show');
            end
            % 
            %	Finally, plot the indivudual features for the largest bin: 
            % 
            if ~suppressPlot
	            individualFeatureCurves = timeCurves;
	            fLast = figure;
	            AxN = axes(fLast);
	            Axes = {};
	            minY = 0;
	            maxY = 0;
	            for iEvent = 1:numel(EventNames)
	            	subplot(AxN);
	            	AxN = subplot(1,numel(EventNames)+1, iEvent);
	            	Axes{iEvent} = AxN;
	            	plot(AxN, -(numel(preCue)-1):Times(iTimepoint), individualFeatureCurves{iEvent,1})
	            	title(AxN,EventNames{iEvent})
	            	if max(individualFeatureCurves{iEvent,1}) > maxY
	            		maxY = max(individualFeatureCurves{iEvent,1});
	        		end
	        		if min(individualFeatureCurves{iEvent,1}) < minY
	            		minY = min(individualFeatureCurves{iEvent,1});
	        		end
	        		xlim(AxN,[-1500,Times(iTimepoint)])
	    		end
	    		AxN = subplot(1,numel(EventNames)+1, numel(EventNames)+1);
	    		Axes{end+1} = AxN;
	    		plot(AxN, [-(numel(preCue)-1):Times(iTimepoint)], th(end).*ones(size(individualFeatureCurves{iEvent,1})))
	    		xlim(AxN,[-1500,Times(iTimepoint)])
	        	title(AxN,'th0')
	    		for iaxes = 1:numel(Axes)
	    			ylim(Axes{iaxes}, [minY, maxY]);
				end
			end
            %
            %
            %
		end

%-------------------------------------------------------------------------------
% V2.14 ------------------------------------------------------------------------
%		Testing gFit Windows...
%
%-------------------------------------------------------------------------------

		function testGFitWindow(obj, baselineWin, gFitWin, simData)
			% 
			% 	The goal is to simulate data in which the baselines are 
			% 	all equal, then see if gFitting causes distortion
			% 
			% 	Created 1/3/19, Mod 1/3/19
			% ----------------------------------------
			% 
			% 	First, check the obj type is appropriate + load variables...
			% 
			if ~obj.isSingleSeshObj, error('Inappropriate Obj Type'), end
			if ~isfield(obj.GLM, 'rawF'), obj.loadRawF, end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);, end
			obj.GLM.flush = {};
			if nargin < 4
				% 
				% 	Calculate the normalizedBaselineDFF...
				% 
				obj.normalizedBaselineDFF(baselineWin, true);
				%
				simData = obj.GLM.flush.nbDFF;
			end 
			% 	Now calculate the gFit on top of the normalized baseline dFF...
			% 
			obj.GLM.flush.testGfit = FX_gfitdF_F_fx_roadmapv1_4(simData, gFitWin);
		end

		function [lp, f, dFF] = gFitBasicFilter(obj, ts, cutoff_f, fs, setObj)
			if nargin < 5
				setObj = false;
			end
			if nargin < 4
				fs = obj.Plot.samples_per_ms*1000;
			end
			if nargin < 3
				cutoff_f = 1/20000;
			end

			steepness = 0.95;

			[lp, f] = lowpass(ts,cutoff_f,fs, 'ImpulseResponse','iir','Steepness',steepness);
			dF = ts - lp;
			dFF = (ts - lp)./lp;

			
			figure, hold on
			plot([1:numel(ts)]./1000,ts, 'DisplayName', 'Raw Signal')
			plot([1:numel(lp)]./1000,lp, 'DisplayName', 'Low Pass');
			% plot([1:numel(dF)]./1000,dF, 'DisplayName', 'Detrended');
			legend
			xlabel('session time (s)')
			figure
			plot([1:numel(dFF)]./1000, dFF, 'DisplayName', 'dFF');
			legend

			fvtool(f, 1000, 1000)
			freqz(f, 1000, 1000)

			if setObj
				obj.gFitLP.dFF = dFF;
				obj.gFitLP.cutoff_f = cutoff_f;
				obj.gFitLP.steepness = steepness;
			end
		end

		function dFF = gfitBox(obj, ts, win)
			if nargin < 2
				win = '200000';
			end
			if ~isstr(win)
				win = num2str(win);
			end
			dFF = FX_gfitdF_F_fx_roadmapv1_4(ts, win);
		end

		function testdFFstruct = testBaselineDistortion(obj, simType)
			if ~obj.isSingleSeshObj, error('Inappropriate Obj Type'), end
			if ~isfield(obj.GLM, 'rawF'), obj.loadRawF, end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);, end
			if strcmpi(simType, 'nbDFF')
				% 
				% 	Simulate data
				% 
				obj.gFitLP.simNB5000 = obj.normalizedBaselineDFF(5000, 1);
				% 
				% 	Filter simulated data
				% 
				[testdFFstruct.lp, testdFFstruct.f, testdFFstruct.dFF] = obj.gFitBasicFilter(obj.gFitLP.simNB5000+1, obj.gFitLP.cutoff_f, obj.Plot.samples_per_ms*1000);
				% 
				%	Filter with the box 200 
				% 
				obj.gFitLP.box200simNB = FX_gfitdF_F_fx_roadmapv1_4(obj.gFitLP.simNB5000+1, '200000');
				% 
				% 	Bin gfit200 data
				% 
				obj.getBinnedTimeseries(obj.GLM.gfit, 'outcome', 6);
				% 
				% 	Plot CTAs...
				% 
				figure,
				subplot(1,5,1)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				title('gFit 200s Boxcar Data')
				% 
				% 	Bin lp DFF
				% 
				obj.getBinnedTimeseries(obj.gFitLP.dFF, 'outcome', 6);
				subplot(1,5,2)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				title(['gFit Basic Filter: fc: ' num2str(obj.gFitLP.cutoff_f) 'Hz'])
				% 
				% 	Bin similated data
				% 
				obj.getBinnedTimeseries(obj.GLM.flush.nbDFF, 'outcome', 6);
				subplot(1,5,3)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				title('Simulated Data: 5 sec Normalized Baseline Method')
				% 
				% 	box200 dFF of simData
				% 
				% obj.getBinnedTimeseries(testdFFstruct.dFF, 'outcome', 6);
				obj.getBinnedTimeseries(obj.gFitLP.box200simNB, 'outcome', 6);
				subplot(1,5,4)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				title(['gFit 200s Boxcar Simulation'])
				% 
				% 	Bin dFF of simData
				% 
				% obj.getBinnedTimeseries(testdFFstruct.dFF, 'outcome', 6);
				obj.getBinnedTimeseries(testdFFstruct.dFF, 'outcome', 6);
				subplot(1,5,5)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				title(['gFit LP Simulation fc: ' num2str(obj.gFitLP.cutoff_f) 'Hz'])
				% 
				% 	Add simulated data to the gFitLP struct
				% 
				obj.gFitLP.nbSimulatedDFF = testdFFstruct.dFF;
				obj.gFitLP.nbSimulated_fc = obj.gFitLP.cutoff_f;
				obj.gFitLP.nbSimulated_baselineWidth = 5000;
			elseif strcmpi(simType, 'expBaseline')
				error('Not implemented')
				% 
				% 	Simulate data
				% 
				simData = obj.GLM.rawF;
				baselineWin = 3000;
				n = numel(obj.GLM.rawF);
				t = [0:n];
				exps = (exp(-1/(n/20)*[0:n])-1 + exp(-1/(n/4)*[0:n])-1+ exp(-1/(n/2)*[0:n])-1+0.5*exp(-1/(100*n)*[0:n])-1+6.3)/5;
				% 
				% 	Determine the indicies of the beginnings of each baseline Period...
				% 
				baselineStart = obj.GLM.pos.cue - baselineWin + 1;
				baselineStart(end+1) = numel(obj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
				for iTrial = 1:numel(obj.GLM.pos.cue)
					baselineIdxs_baseline = baselineStart(iTrial):obj.GLM.pos.cue(iTrial);
					simData(baselineIdxs_baseline) = exps(baselineIdxs_baseline);	
				end
				figure, hold on
				plot(obj.GLM.rawF, 'DisplayName', 'RawF')
				plot(simData, 'DisplayName', 'simData')
				legend		
				% 
				% 	Filter simulated data
				% 
				if strcmpi(gfitType, 'lopass')
					[testdFFstruct.lp, testdFFstruct.f, testdFFstruct.dFF] = obj.gFitBasicFilter(simData, cutoff_f, fs);
				elseif strcmpi(gfitType, 'box200')
					testdFFstruct.dFF = FX_gfitdF_F_fx_roadmapv1_4(simData, '200000');
				end
				% 
				% 	Bin gfit200 data
				% 
				obj.getBinnedTimeseries(obj.GLM.gfit, 'outcome', 6);
				% 
				% 	Plot CTAs...
				% 
				figure,
				subplot(1,3,1)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				title('gFit 200 Boxcar Data')
				% 
				% 	Bin similated data
				% 
				obj.getBinnedTimeseries(simData, 'outcome', 6);
				subplot(1,3,2)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				title('Simulated Data: 3 sec Exponential Baseline Method')
				% 
				% 	Bin dFF of simData
				% 
				obj.getBinnedTimeseries(testdFFstruct.dFF, 'outcome', 6);
				subplot(1,3,3)
				obj.plot('CTA', [3,5], true, obj.Plot.smooth_kernel, 'last-to-first', true);
				if strcmpi(gfitType, 'lopass')
					title(['gFit Basic Filter: fc: ' num2str(cutoff_f) 'Hz'])
				elseif strcmpi(gfitType, 'box200')
					title(['gFit 200 Boxcar on simData'])
				end
			end

		end


		function dFF = normalizedMultiBaselineDFF(obj, baselineWin, nTrials, ts)
			if nargin < 4
				if ~isfield(obj.GLM, 'rawF'), obj.loadRawF, end
				ts = obj.GLM.rawF;
			end
			% 
			% 	Start by correcting away noise from rawF
			% 
			% 1. Smooth the whole day timeseries (window is 10 seconds)
			disp('killing noise with 1,000 ms window, moving');
			Fraw = smooth(ts, 1000, 'moving');
			% Fraw = smooth(SNc_values, 1000, 'gauss');
			disp('noise killing complete');

			% 2. Subtract the smoothed curve from the raw trace 			(Fraw)
			Fraw = ts - Fraw;

			% 2b. Eliminate all noise > 15 STD above the whole trace 		(Frs = Fraw-singularities)
				% find points > 15 STD above/below trace and turn to average of surrounding points
			ignore_pos = find(Fraw > 15*nanstd(Fraw));
			% disp(['Ignored points SNc: ', num2str(ignore_pos)]);
			for ig = ignore_pos
				ts(ig) = mean([ts(ig-1), ts(ig+1)],2);
			end
			% 
			%	We get F0 = median of n trials baselines
			% 
			% 	Then we normalize all the points in the trial to the n/2-trial baseline on either side (n+1 trials total!)
			% 
			% 	For the edges, we will just take median of however many trials are in range... Can exclude these if necessary
			% 
			% 	To be able to handle chop data, we need to exclude nans from the mean...
			% 
			if nargin < 3
				nTrials = 10;
			elseif rem(nTrials, 2)
				nTrials = nTrials - 1;
				warning(['nTrials must be even, because use n/2 trials on either side. nTrials reduced to ' num2str(nTrials)]);
			end
			if ~obj.GLM.isSingleSeshObj, error('Inappropriate Obj Type'), end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);, end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'lick'), obj.GLM.pos.lick = obj.getXPositionsWRTgfit(obj.GLM.lick_s);, end
			% 
			% 	Determine the indicies of the beginnings of each baseline Period...
			% 
			obj.GLM.pos.baselineStart = obj.GLM.pos.cue - baselineWin + 1;
			obj.GLM.pos.baselineStart(end+1) = numel(ts); % tack on the full length so that we can correct the entire signal...
			% 
			% 	Initialize the baseline dFF
			% 
			obj.gFitLP.nMultibDFF.dFF = nan(size(ts));
			obj.gFitLP.nMultibDFF.style = ['median | baseline window(ms) = ' num2str(baselineWin) ' | nTrials (not including nth trial) = ' num2str(nTrials), ' | gFit: normalized multibaseline | symmetric'];
			obj.gFitLP.nMultibDFF.edgeTrials = [1:nTrials/2, numel(obj.GLM.pos.cue) - nTrials/2:numel(obj.GLM.pos.cue)];
			% 
			% 	Find the baseline indices and Run the dF/F correction... as well as the number of licks in range.
			% 
			F0s = nan(size(obj.GLM.pos.cue));
			obj.gFitLP.nMultibDFF.nLicksInBaseline = zeros(size(obj.GLM.pos.cue));
			for iTrial = 1:numel(obj.GLM.pos.cue)
				if iTrial == 1 && obj.GLM.pos.baselineStart(iTrial) <= 0
					nanpad = nan(1, 1-obj.GLM.pos.baselineStart(iTrial));
					obj.GLM.flush.baselineIdxs_baseline((iTrial-1)*baselineWin + 1:iTrial*baselineWin) = [nanpad, 1:obj.GLM.pos.cue(iTrial)];
					F0s(iTrial) = nanmedian(ts(1:obj.GLM.pos.cue(iTrial)));
					obj.gFitLP.nMultibDFF.nLicksInBaseline(iTrial) = sum(ismember(find(obj.GLM.pos.lick > 1), find(obj.GLM.pos.lick < 1+baselineWin)));
				else
					obj.GLM.flush.baselineIdxs_baseline((iTrial-1)*baselineWin + 1:iTrial*baselineWin) = obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.cue(iTrial);
					F0s(iTrial) = nanmedian(ts(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.cue(iTrial)));
					obj.gFitLP.nMultibDFF.nLicksInBaseline(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+baselineWin)));
				end
            end
            figure 
            subplot(1,2,1);
            plot(F0s, 'DisplayName', 'Median Baseline')
            movingAve = smooth(F0s, nTrials+1, 'moving');
            hold on, plot(movingAve, 'DisplayName', 'F0')
            xlabel('Trial #')
            ylabel('F (V)')
            subplot(1,2,2);
            bar(obj.gFitLP.nMultibDFF.nLicksInBaseline)
            xlabel('Trial #')
            ylabel('# licks in baseline')
			% 
			% 	Now normalize to multibaseline:
			% 
			for iTrial = 1:numel(obj.GLM.pos.cue)
				if ismember(iTrial, obj.gFitLP.nMultibDFF.edgeTrials)
					if iTrial < numel(obj.GLM.pos.cue)/2
						nLeftSideTrials = iTrial-1;
						nRightSideTrials = nTrials/2;
					else
						nLeftSideTrials = nTrials/2;
						nRightSideTrials = numel(obj.GLM.pos.cue) - iTrial;
					end
				else
					nLeftSideTrials = nTrials/2;
					nRightSideTrials = nTrials/2;
				end
				F0 = nanmean(F0s(iTrial-nLeftSideTrials:iTrial+nRightSideTrials));
				if iTrial == 1 && obj.GLM.pos.baselineStart(iTrial) <= 0
					nanpad = nan(1, 1-obj.GLM.pos.baselineStart(iTrial));					
					F = ts(1:obj.GLM.pos.baselineStart(iTrial + 1)-1);
					% 
					% 	Need to handle nans... this will happen automatically - any nan points will remain nans after this step. This is ok.
					% 
					obj.gFitLP.nMultibDFF.dFF(1:obj.GLM.pos.baselineStart(iTrial + 1)-1) = (F - F0)/F0;	
				else
					F = ts(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.baselineStart(iTrial + 1)-1);
					% 
					% 	Need to handle nans... this will happen automatically - any nan points will remain nans after this step. This is ok.
					% 
					obj.gFitLP.nMultibDFF.dFF(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.baselineStart(iTrial + 1)-1) = (F - F0)/F0;	
				end
			end
			% 
			% 	Set the pre-session with moving boxcar...
			% 
			boxwin = nTrials*20*1000;
			preSesh = FX_gfitdF_F_fx_roadmapv1_4(ts(1:boxwin*2), '200000');
			obj.gFitLP.nMultibDFF.dFF(1:obj.GLM.pos.baselineStart(1)-1) = preSesh(1:obj.GLM.pos.baselineStart(1)-1);
			dFF = obj.gFitLP.nMultibDFF.dFF;
            %
            %   Kill noise
            %
            dFF(dFF>15*nanstd(dFF)) = nan;
           
		end


		function dFF = normalizedBaselineDFF(obj, baselineWin, setBaselineZero)
			if nargin < 3
				setBaselineZero = false;
			end
			if ~obj.isSingleSeshObj, error('Inappropriate Obj Type'), end
			if ~isfield(obj.GLM, 'rawF'), obj.loadRawF, end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);, end
			% 
			% 	Determine the indicies of the beginnings of each baseline Period...
			% 
			obj.GLM.pos.baselineStart = obj.GLM.pos.cue - baselineWin + 1;
			obj.GLM.pos.baselineStart(end+1) = numel(obj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
			% 
			% 	Initialize the baseline dFF
			% 
			obj.GLM.flush.nbDFF = obj.GLM.rawF;
			% 
			% 	Find the baseline indices and Run the dF/F correction...
			% 
			for iTrial = 1:numel(obj.GLM.pos.cue)
				obj.GLM.flush.baselineIdxs_baseline((iTrial-1)*baselineWin + 1:iTrial*baselineWin) = obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.cue(iTrial);
				% obj.GLM.flush.baselineIdxs_trial = obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.baselineStart(iTrial + 1)-1;
				F0 = nanmean(obj.GLM.rawF(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.cue(iTrial)));
				F = obj.GLM.flush.nbDFF(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.baselineStart(iTrial + 1)-1);
				obj.GLM.flush.nbDFF(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.baselineStart(iTrial + 1)-1) = (F - F0)/F0;
			end
			% 
			% 	If the baselines should all be set to exactly zero after dF/F, do that here:
			% 
			if setBaselineZero
				obj.GLM.flush.nbDFF(obj.GLM.flush.baselineIdxs_baseline) = 0;
				obj.GLM.flush.nbDFF(1:obj.GLM.flush.baselineIdxs_baseline(1)) = 0;
			end
			dFF = obj.GLM.flush.nbDFF;
		end


		function simData = simulateEqualBaseline(obj, baselineWin)
			warning('I''m not sure how to do this! We want normdFF to make all of these equal when running normBaseline...')
			if nargin < 3
				setBaselineZero = false;
			end
			if ~obj.isSingleSeshObj, error('Inappropriate Obj Type'), end
			if ~isfield(obj.GLM, 'rawF'), obj.loadRawF, end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);, end
			% 
			% 	Determine the indicies of the beginnings of each baseline Period...
			% 
			obj.GLM.pos.baselineStart = obj.GLM.pos.cue - baselineWin + 1;
			obj.GLM.pos.baselineStart(end+1) = numel(obj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
			% 
			% 	Initialize the simData
			% 
			simData = obj.GLM.rawF;
			% 
			% 	Find the baseline indices and Run the dF/F correction...
			% 
			for iTrial = 1:numel(obj.GLM.pos.cue)
				obj.GLM.flush.baselineIdxs_baseline((iTrial-1)*baselineWin + 1:iTrial*baselineWin) = obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.cue(iTrial);
				F0 = nanmean(obj.GLM.rawF(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.cue(iTrial)));
				simData(obj.GLM.pos.baselineStart(iTrial):obj.GLM.pos.cue(iTrial)) = F0;
			end
		end





		function isSingleSesh = isSingleSeshObj(obj)
			isSingleSesh = strcmp(obj.iv.setStyle, 'single-day');
		end

		function loadRawF(obj, sigStruct)
			if nargin < 2
				% 
				% 	Add/Overwrite existing emgFit, emgTimes using UI input
				% 
				disp('	Select the Session datafile to use')
				sigStruct = pullVarFromBaseWorkspace(obj, 'Select Raw Signal structure');
				if isempty(sigStruct)
					[file,path] = uigetfile('*.mat','Select the day with EMG data to use');
					if isnumeric(file) && file == 0 && xpath == 0
						warning('No raw signal-datasets present. Quitting data search. You can always add later manually with obj.loadRawF()')
						return
					end
					sigStruct = load([path,file]);
				end
			end
			f = fieldnames(sigStruct);
            fidx = find(cellfun(@(x) contains(x,obj.iv.signalname), f)>0);
            sigStruct = getfield(sigStruct, f{fidx});
			rawF  = sigStruct.values;
            obj.GLM.rawF = rawF;			
		end

%-------------------------------------------------------------------------------
%
%		Checking out if Baseline Differences are real....
%
%-------------------------------------------------------------------------------

		function pairedBaselineRawF(obj)
			% 
			%	The goal is to check out raw baseline differences...
			% 
			% 	Time windows defined relative to cue-on
			% 
			% windows = {[1,100], [101,200], [201,300], [301,400], [401,500], [501,600], [601,700], [701,800], [701,800], [801,900], [901,1000], [1001,1100], [1101,1200], [1201,1300], [1301,1400], [1401,1500], [1501,2500], [2501,3500], [3501,4500], [4501,5500]};
					% winspan = 30000;
					% windivs = 100;
					% windows = cell(winspan/windivs,1);

					% for idiv = 1:winspan/windivs
					% 	windows{idiv} = [1+windivs*(1-idiv),windivs*idiv];
					% end
					% cat1_s = [0.7,1.5];
					% cat2_s = [4,7];
			winspan = 100000;
			windivs = 5000;
			smalldivs = 5000;
			smallSize = 5000;
			ndivsSmall = smallSize/smalldivs;
			ndivsBig = (winspan-smallSize)/windivs;
			ndivs = ndivsSmall+ndivsBig;
			windows = cell(ndivs,1);
			for idiv = 1:ndivsSmall
				windows{idiv} = [1+smalldivs*(idiv-1),smalldivs*idiv];
			end
			for idiv = 1:ndivsBig
				windows{idiv+ndivsSmall} = smallSize+[1+windivs*(idiv-1),windivs*idiv];
			end
			% cat1_s = [0.7,3.333];
			cat1_s = [0,0.5];
			% cat1_s = [0.7,1.3];
				%             cat1_s = [0.7,1.8];
				%             cat2_s = [3.6,7];
			% cat2_s = [4,7];
			% cat2_s = [3.333,7];
			cat2_s = [3.333,7];
				%             cat2_s = [1.5	,7];
			% 
			% ------------------------------------------------------------------
			% 
			% 	First, check the obj type is appropriate + load variables...
			% 
			if ~obj.isSingleSeshObj, error('Inappropriate Obj Type'), end
			if ~isfield(obj.GLM, 'rawF'), obj.loadRawF, end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s);, end
			lTBT = 17*ones(1, numel(obj.GLM.cue_s)); 
			lTBT(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
			% 
			%	Find all trials in cat1 and cat2...	 	
			% 
			cat1Trials = find(lTBT > cat1_s(1) & lTBT < cat1_s(2));
			cat2Trials = find(lTBT > cat2_s(1) & lTBT < cat2_s(2));
			disp(['#cat1 = ' num2str(numel(cat1Trials)), ' || #cat2 = ' num2str(numel(cat2Trials))])
			% 
			% 	Find all consecutive 1->2 indicies
			% 
			consec12 = cat1Trials(find(ismember(cat1Trials,cat2Trials-1)));
			consec21 = cat2Trials(find(ismember(cat2Trials, cat1Trials-1)));
			disp(['#Consec 1->2 = ' num2str(numel(consec12)), ' || #Consec 2->1 = ' num2str(numel(consec21))])
			figure, hold on
			plot(cat1Trials, ones(size(cat1Trials)), 'co', 'DisplayName', 'Category 1 Trials')
			plot(cat2Trials, 2*ones(size(cat2Trials)), 'go', 'DisplayName', 'Category 2 Trials')
			plot(consec12, 2*ones(size(consec12)), 'bo', 'DisplayName', 'Consecutive 1-2')
			plot(consec21, ones(size(consec21)), 'ko', 'DisplayName', 'Consecutive 2-1')
			legend();
			title('Trial Positions for Each Category in Session')
			xlabel('Trial #')
			ylabel('Trial Category')
			% 
			% 	For each window, calculate the baseline for the rawF and dF/F...	
			% 
			figure
			ax1 = subplot(1,2,1);
			hold(ax1, 'on');
			plot([-(windows{end}(2))/1000,0], [0,0], 'k-', 'DisplayName', 'zero--')
			title('Cat1 Trial MINUS Cat2 Trial mean dF/F: 1-2')
			xlabel('Time Relative to Cue (s)')
			ylabel('Cat 1 - Cat 2 mean dF/F')

			ax2 = subplot(1,2,2);
			hold(ax2, 'on');
			plot([-(windows{end}(2))/1000,0], [0,0], 'k-', 'DisplayName', 'zero--')
			title('Cat2 Trial MINUS Cat1 Trial mean dF/F: 2-1')
			xlabel('Time Relative to Cue (s)')
			ylabel('Cat 2 - Cat 1 mean dF/F')


			figure
			ax3 = subplot(1,2,1);
			hold(ax3, 'on');
			plot([-(windows{end}(2))/1000,0], [0,0], 'k-', 'DisplayName', 'zero--')
			title('Cat1 Trial MINUS Cat2 Trial mean RawF: 1-2')
			xlabel('Time Relative to Cue (s)')
			ylabel('Cat 1 - Cat 2 mean F')

			ax4 = subplot(1,2,2);
			hold(ax4, 'on');
			plot([-(windows{end}(2))/1000,0], [0,0], 'k-', 'DisplayName', 'zero--')
			title('Cat2 Trial MINUS Cat1 Trial mean RawF: 2-1')
			xlabel('Time Relative to Cue (s)')
			ylabel('Cat 2 - Cat 1 mean F')


			medDFF = cell(numel(windows), 1);
			medRawF = cell(numel(windows), 1);
			for iWin = 1:numel(windows)
				if rem(iWin,0.1*numel(windows)) == 0
					disp(['	Window #' num2str(iWin) '/' num2str(numel(windows))])
				end
				win1Idx = obj.GLM.pos.cue - windows{iWin}(2);
				win2Idx = obj.GLM.pos.cue - windows{iWin}(1);
				medDFF{iWin} = nan(numel(obj.GLM.pos.cue),1);
				medRawF{iWin} = nan(numel(obj.GLM.pos.cue),1);
				for iTrial = 1:numel(obj.GLM.pos.cue)
					try
						medDFF{iWin}(iTrial,1) = mean(obj.GLM.gfit(win1Idx(iTrial):win2Idx(iTrial)));
						medRawF{iWin}(iTrial,1) = mean(obj.GLM.rawF(win1Idx(iTrial):win2Idx(iTrial)));
					catch
						% medDFF{iWin}(iTrial) = nan;
						% medRawF{iWin}(iTrial) = nan;
					end
				end
				% 
				% 	Get the difference in the baseline for the DFF and RawF cases...
				% 
				delDFF1m2{iWin} = medDFF{iWin}(consec12) - medDFF{iWin}(consec12+1);
				delDFF2m1{iWin} = medDFF{iWin}(consec21) - medDFF{iWin}(consec21+1);
				medDelDFF1m2{iWin} = nanmean(delDFF1m2{iWin});
				medDelDFF2m1{iWin} = nanmean(delDFF2m1{iWin});
				medCat1DFF{iWin} = nanmean(medDFF{iWin}(cat1Trials));
				medCat2DFF{iWin} = nanmean(medDFF{iWin}(cat2Trials));
				medDelDFFAll1mAll2{iWin} = medCat1DFF{iWin} - medCat2DFF{iWin};

				delRawF1m2{iWin} = medRawF{iWin}(consec12) - medRawF{iWin}(consec12+1);
				delRawF2m1{iWin} = medRawF{iWin}(consec21) - medRawF{iWin}(consec21+1);
				medDelRawF1m2{iWin} = nanmean(delRawF1m2{iWin});
				medDelRawF2m1{iWin} = nanmean(delRawF2m1{iWin});
				medCat1RawF{iWin} = nanmean(medRawF{iWin}(cat1Trials));
				medCat2RawF{iWin} = nanmean(medRawF{iWin}(cat2Trials));
				medDelRawFAll1mAll2{iWin} = medCat1RawF{iWin} - medCat2RawF{iWin};

				% figure, hold on
				% plot([1,2], [0,0], 'k-', 'DisplayName', 'zero--')
				% plot(ones(size(delDFF1m2{iWin})), delDFF1m2{iWin}, 'ko', 'DisplayName', 'Consecutive 1-2')
				% plot(2*ones(size(delDFF2m1{iWin})), delDFF2m1{iWin}, 'ko', 'DisplayName', 'Consecutive 2-1')
				% plot(1, medDelDFF1m2{iWin}, 'ro', 'DisplayName', 'mean Cat 1 - mean Cat 2 (PAIRED)')
				% plot(2, -medDelDFF1m2{iWin}, 'ro', 'DisplayName', 'mean Cat 2 - mean Cat 1 (PAIRED)')
				% plot(1, medDelDFFAll1mAll2{iWin}, 'co', 'DisplayName', 'mean of All Cat 1 - mean of All Cat 2 (nonconsec)')
				% plot(2, -medDelDFFAll1mAll2{iWin}, 'co', 'DisplayName', 'mean of All Cat 2 - mean of All Cat 1 (nonconsec)')
				% legend();
				% title(['First Trial MINUS Second Trial mean dFF in window: ' mat2str(windows{iWin})])
				% ylabel('First Trial MINUS Second Trial dFF in window')
				% xlabel('First trial Category')

				% plot(ax1, -mean(windows{iWin}(2)-1)/1000.*ones(size(delDFF1m2{iWin})), delDFF1m2{iWin}, 'ko-', 'DisplayName', 'Consecutive 1-2')
				% plot(ax2, -mean(windows{iWin}(2)-1)/1000.*ones(size(delDFF2m1{iWin})), delDFF2m1{iWin}, 'ko-', 'DisplayName', 'Consecutive 2-1')
				plot(ax1, -mean(windows{iWin}(2)-1)/1000, medDelDFF1m2{iWin}, 'ro', 'DisplayName', 'mean Cat 1 - mean Cat 2 (PAIRED)')
				plot(ax2, -mean(windows{iWin}(2)-1)/1000, medDelDFF2m1{iWin}, 'ro', 'DisplayName', 'mean Cat 2 - mean Cat 1 (PAIRED)')
				plot(ax1, -mean(windows{iWin}(2)-1)/1000, medDelDFFAll1mAll2{iWin}, 'co', 'DisplayName', 'mean of All Cat 1 - mean of All Cat 2 (nonconsec)')
				plot(ax2, -mean(windows{iWin}(2)-1)/1000, -medDelDFFAll1mAll2{iWin}, 'co', 'DisplayName', 'mean of All Cat 2 - mean of All Cat 1 (nonconsec)')


				% plot(ax3, -mean(windows{iWin}(2)-1)/1000.*ones(size(delRawF1m2{iWin})), delRawF1m2{iWin}, 'ko-', 'DisplayName', 'Consecutive 1-2')
				% plot(ax4, -mean(windows{iWin}(2)-1)/1000.*ones(size(delRawF2m1{iWin})), delRawF2m1{iWin}, 'ko-', 'DisplayName', 'Consecutive 2-1')
				plot(ax3, -mean(windows{iWin}(2)-1)/1000, medDelRawF1m2{iWin}, 'ro', 'DisplayName', 'mean Cat 1 - mean Cat 2 (PAIRED)')
				plot(ax4, -mean(windows{iWin}(2)-1)/1000, medDelRawF2m1{iWin}, 'ro', 'DisplayName', 'mean Cat 2 - mean Cat 1 (PAIRED)')
				plot(ax3, -mean(windows{iWin}(2)-1)/1000, medDelRawFAll1mAll2{iWin}, 'co', 'DisplayName', 'mean of All Cat 1 - mean of All Cat 2 (nonconsec)')
				plot(ax4, -mean(windows{iWin}(2)-1)/1000, -medDelRawFAll1mAll2{iWin}, 'co', 'DisplayName', 'mean of All Cat 2 - mean of All Cat 1 (nonconsec)')

			end
			legend(ax1);
			legend(ax2);
			legend(ax3);
			legend(ax4);

			obj.Stat.baselineCheck.windowsWRTcue = windows;
			obj.Stat.baselineCheck.medDFF = medDFF;
			obj.Stat.baselineCheck.medRawF = medRawF;
		end

%-------------------------------------------------------------------------------
% V2.15 ------------------------------------------------------------------------
%		Paired Trial Analyses for CTA/LTA 
% 		-- full timeseries version of binning data
%			We will handle this as an alternative version of binning in the 
% 			getBinnedTimeseries for arbitrary ts
%-------------------------------------------------------------------------------
		function [sNc, sNl] = getBinnedTimeseries(obj, ts, Mode, nbins, timePad, trialsIncluded, samples_per_ms_xticks, verbose, handles)
			% 
			% 	handles is a 1x2 vector of subplot handles for histogram mode (hist_h, cdf_h)
			% 
			% 
			% 	Will bin timeseries with the session behavioral markers in obj.GLM
			% 		NOTE: timepad is in SAMPLES -- adjust it to the signal of interest
			% 
			% 	Modes:
			% 		'Custom' -- nbins is the user input bin windows
			% 
			% 		'histogram' -- used to pull out histogram and cdfs easily
			% 
			% 		'SingleTrial' -- makes a bin for every trial in the session
			% 
			% 		'Times' -- nbins = total number of bins.
			% 
			% 		'Trials' -- nbins = number of trials in each bin
			% 
			% 		'Outcome' -- nbins has no effect
			% 	
			% 		'Paired' -- nbins instead is a cell:
			% 			{# of bins n, [cat1min, cat1max], [cat2min, cat2max]}. Time windows wrt cue on in ms
			% 
			% 		'Triplet' -- nbins instead is a cell:
			% 			{# of bins n, [cat1min, cat1max], [cat2min, cat2max]}. Time windows wrt cue on in ms
			% 
			% 		'Paired-nLicksBaseline' -- nbins instead is a cell:
			% 			{# of bins n, [cat1min, cat1max], [cat2min, cat2max], baselineWindow (ms)}. Time windows wrt cue on in ms 
			% 
			%		'Times-Unbiased' -- nbins is a cell: 
			% 			{# of bins in range, [range to bin evenly mn, mx]}
			% 			A bin is added for licks out of range early and late (+2 bins)
			% 			A bin is added for all excluded/noLick trials Range [0, 0.0001]
			% 		early vs late with same proportion of earlies and lates on trial n-1 going in to each bin
			% 			-- use this only with dF/F
			% 
			% 		'Histogram' -- plots a histogram of the trialsIncluded
			% 
			% 	sNc = cell array of vectors with the number of samples going into timepoint for each bin.
			% 	sNl = likewise, but for the LTA
			% 
			if nargin < 9
				handles = [];
			end
			
			if nargin < 8
				verbose = true;
			end
            if size(ts, 2) > 1
                ts = ts';
            end
			sNc = {};
			sNl = {};
			if nargin < 7 || isempty(samples_per_ms_xticks)
				samples_per_ms_xticks = obj.Plot.samples_per_ms;
			end

			if nargin < 5
				timePad = 30000;
            end
            if nargin < 4 && ~strcmpi(Mode, 'Paired')
                nbins = obj.BinParams.ogBins;
            elseif nargin <4 && strcmpi(Mode, 'Paired')
            	nbins = {2, [0,3.30], [3.34,7]};
            end
            if ~obj.GLM.isSingleSeshObj, error('Inappropriate Obj Type'), end
			if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'lampOff'), obj.GLM.pos.lampOff = obj.getXPositionsWRTgfit(obj.GLM.lampOff_s);, end
			if ~isfield(obj.GLM.pos, 'cue'), obj.GLM.pos.cue = obj.getXPositionsWRTgfit(obj.GLM.cue_s); end
			% if ~isfield(obj.GLM.pos, 'flick'), obj.GLM.pos.flick = obj.getXPositionsWRTgfit(obj.GLM.firstLick_s); end %obj.GLM.pos.fLick = round(1000*obj.GLM.firstLick_s*obj.Plot.samples_per_ms)+1;, end
% 			if ~isfield(obj.GLM, 'exclusionsTaken') || ~obj.GLM.exclusionsTaken, warning('Excluded trials were not omitted from this binning!'), end
			% 
			% 	Allow user to select trials to include. If UI trials not in range, ignore them. (useful for plot stim vs nostim cases)
			% 
			% 
			if nargin < 6 || isempty(trialsIncluded)
				trialsIncluded = obj.GLM.fLick_trial_num;
				flick_Idx = 1:numel(obj.GLM.firstLick_s);
			else
				trialsIncluded = obj.GLM.fLick_trial_num(ismember(obj.GLM.fLick_trial_num, trialsIncluded));
				flick_Idx = find(ismember(obj.GLM.fLick_trial_num, trialsIncluded));
			end

			fLick = nan(size(obj.GLM.cue_s));
            % if ~isfield(obj.GLM.pos, 'fLick')
        	if ~isfield(obj.GLM.pos, 'flick')
                % check samples_per_ms...
                if obj.Plot.samples_per_ms ~= 1/(1000*mode(obj.GLM.gtimes(2:end) - obj.GLM.gtimes(1:end-1)))
                    warning('Correcting sampling rate for this old obj')
                    obj.Plot.samples_per_ms = 1/(1000*mode(obj.GLM.gtimes(2:end) - obj.GLM.gtimes(1:end-1)));
                end
                % obj.GLM.pos.fLick = round(1000*obj.GLM.firstLick_s*obj.Plot.samples_per_ms)+1;
                obj.GLM.pos.flick = obj.getXPositionsWRTgfit(obj.GLM.firstLick_s);
                if nargin < 7
                	samples_per_ms_xticks = obj.Plot.samples_per_ms;
            	end
            end
			fLick(trialsIncluded) = obj.GLM.pos.flick(flick_Idx);
			if verbose
				disp('=================================================')
				disp('Overwritting previously-binned timeseries data...')
				disp('=================================================')
			end
			obj.ts = {};


			if strcmpi(Mode, 'histogram')
				all_fl_wrtc_s = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_s(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);

				if numel(handles) < 2
					figure,
					obj.GLM.flush.hist_h = subplot(1,2,1);
					obj.GLM.flush.ecdf_h = subplot(1,2,2);
					hold(obj.GLM.flush.hist_h, 'on')
					hold(obj.GLM.flush.ecdf_h, 'on')
				else
					obj.GLM.flush.hist_h = handles(1);
					obj.GLM.flush.ecdf_h = handles(2);
					hold(obj.GLM.flush.hist_h, 'on')
					hold(obj.GLM.flush.ecdf_h, 'on')
				end
				h = histogram(obj.GLM.flush.hist_h, all_fl_wrtc_s);
				h.FaceColor = 'k';
				obj.GLM.flush.histogram = h;
				obj.GLM.flush.all_fl_wrtc_s_hist = all_fl_wrtc_s;
				[obj.GLM.flush.ecdf_f, obj.GLM.flush.ecdf_x] = ecdf(all_fl_wrtc_s(all_fl_wrtc_s > 0.7));
				
				plot(obj.GLM.flush.ecdf_h, obj.GLM.flush.ecdf_x, obj.GLM.flush.ecdf_f, 'k');
				% use h = obj.GLM.flush.histogram;, Nbins = morebins(h) or lessbins(h) to adjust nbins
				% 	then use [N,edges] = histcounts(obj.GLM.flush.all_fl_wrtc_s_hist,Nbins)
				% 	ylim([0, max(N(2:end))])
				%  xlim([0,7])

			elseif strcmpi(Mode, 'singleTrial')
				if verbose,	disp(['Attempting to bin data in single trials... (' datestr(now,'HH:MM AM') ') \n']);, end
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
				% 
				% 	Don't want to include excluded trials, so...
				% 
				[sorted_afltbt,trials_in_each_bin] = sort(all_fl_wrtc_ms);
				nonex_Idx = find(sorted_afltbt > 0);
				sorted_ex_afltbt = sorted_afltbt(nonex_Idx);
				trials_in_each_bin = trials_in_each_bin(nonex_Idx);
				binEdges = [sorted_ex_afltbt(1)-0.00001, sorted_ex_afltbt'+0.00001];
				
				nTr = numel(all_fl_wrtc_ms);
				nEx = numel(find(sorted_afltbt == 0));
				nbins = numel(trials_in_each_bin);


				if verbose, disp(['nbins: ' num2str(nbins), ' | nTrials: ' num2str(nTr), ' | nExcluded: ' num2str(nEx)]);, end
				sNc = cell(1, nbins);
				sNl = cell(1, nbins);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				

                trials_in_each_bin = num2cell(trials_in_each_bin);
				for ibin = 1:nbins
					if verbose && rem(ibin, nbins*.1) == 0
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					end
					
					if numel(trials_in_each_bin{ibin}) > 1
						error('This should always be 1, but was more than 1')
					elseif numel(trials_in_each_bin{ibin}) < 1
						error('This should always be 1, but was 0')
					end
					% 
					% 	Get CTA running average for this bin...
					% 
                    obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					nC = nan(size(obj.ts.BinnedData.CTA{ibin}));
					nL = nan(size(obj.ts.BinnedData.LTA{ibin}));
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						if c1 < 0
							trimTS = [nan(-c1 + 1, 1); ts]; 
							nxt = [trimTS(1:c2-c1+1)]';
							nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place	
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
                        elseif c2 > numel(ts)
                            extraelements = c2 - numel(ts);
                            % trimTS = [ts; nan(extraelements, 1)];
                            % nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
                            trimTS = [ts; nan(extraelements, 1)];
                            nxt = [trimTS(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
						else
							% nxt = [ts(c1:c2) ./n]'; % keeps nan in place
							nxt = [ts(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]); % ignores the nans
							% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
						end
						%
						l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
						l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
						if l1 < 0
							trimTS = [nan(-l1 + 1, 1); ts];
							% nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
							nxt = [trimTS(1:l2-l1+1)]'; % keeps nan in place	
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        elseif l2 > numel(ts)
                            extraelements = l2 - numel(ts);
                            trimTS = [ts; nan(extraelements, 1)];
							% nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
							nxt = [trimTS(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        else
							% nxt = [ts(l1:l2)./n]'; % keeps nan in place
							nxt = [ts(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
							% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
						end
						sNc{ibin} = nC;
						sNl{ibin} = nL;
                    end
					% 
					% 	Append the legend
					% 
					obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;


			elseif strcmpi(Mode, 'custom')
				if verbose,	disp(['Attempting to bin data based on UI-defined windows... (' datestr(now,'HH:MM AM') ') \n']);, end
				% 
				% time_per_bin_ms = obj.iv.total_time_ / nbins;
				binEdges = nbins;
				if binEdges(1) <= 0
					binEdges(1) = 1;
				end
				nbins = numel(binEdges) - 1;
				if verbose, disp(['nbins: ' num2str(nbins) ' || binEdges: ' mat2str(binEdges)]);, end
				sNc = cell(1, nbins);
				sNl = cell(1, nbins);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                % all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                % all_fl_wrtc_ms = nansum(all_fl_wrtc_ms, 3); 
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
                trials_in_each_bin = cell(nbins, 1);
				for ibin = 1:nbins
					if verbose && rem(ibin, nbins*.1) == 0
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					end
					ll = find(all_fl_wrtc_ms >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
					trials_in_each_bin{ibin} =  ll(ismember(ll, ul));
					% 
					% 	Get CTA running average for this bin...
					% 
                    obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					nC = nan(size(obj.ts.BinnedData.CTA{ibin}));
					nL = nan(size(obj.ts.BinnedData.LTA{ibin}));
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						if c1 < 0
							trimTS = [nan(-c1 + 1, 1); ts]; 
							nxt = [trimTS(1:c2-c1+1)]';
							nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place	
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
                        elseif c2 > numel(ts)
                            extraelements = c2 - numel(ts);
                            % trimTS = [ts; nan(extraelements, 1)];
                            % nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
                            trimTS = [ts; nan(extraelements, 1)];
                            nxt = [trimTS(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
						else
							% nxt = [ts(c1:c2) ./n]'; % keeps nan in place
							nxt = [ts(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]); % ignores the nans
							% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
						end
						%
						l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
						l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
						if l1 < 0
							trimTS = [nan(-l1 + 1, 1); ts];
							% nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
							nxt = [trimTS(1:l2-l1+1)]'; % keeps nan in place	
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        elseif l2 > numel(ts)
                            extraelements = l2 - numel(ts);
                            trimTS = [ts; nan(extraelements, 1)];
							% nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
							nxt = [trimTS(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        else
							% nxt = [ts(l1:l2)./n]'; % keeps nan in place
							nxt = [ts(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
							% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
						end
						sNc{ibin} = nC;
						sNl{ibin} = nL;
                    end
					% 
					% 	Append the legend
					% 
					obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;



			elseif strcmpi(Mode, 'Times')
				if verbose, disp(['Attempting to bin data with even blocks of time... (' datestr(now,'HH:MM AM') ') \n']);, end
				% 
				% 	Divide the total trial time into equal sized bins of time
				% 		e.g., 17 bins = [0:1s], [1s:2s], ... , [16s:17s]
				% 	We will allow the last time bin to be smaller than the rest
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				time_per_bin_ms = obj.iv.total_time_ / nbins;
				binEdges = 1:time_per_bin_ms:obj.iv.total_time_;
                % Make sure we have the right number of bins...
                if length(binEdges) < nbins + 1
                    binEdges(end+1) = obj.iv.total_time_;
                end
				if verbose, disp(['nbins: ' num2str(nbins) ' || time per bin (ms): ' num2str(time_per_bin_ms) ' || binEdges: ' mat2str(binEdges)]);, end
				sNc = cell(1, nbins);
				sNl = cell(1, nbins);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                % all_fl_wrtc_ms = cat(3,obj.Plot.wrtCue.Lick.ms.all_ex_first_licks,obj.Plot.wrtCue.Lick.ms.f_ex_lick_rxn); 
                % all_fl_wrtc_ms = nansum(all_fl_wrtc_ms, 3); 
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
                trials_in_each_bin = cell(nbins, 1);
				for ibin = 1:nbins
					if verbose && rem(ibin, nbins*.1) == 0
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					end
					ll = find(all_fl_wrtc_ms >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
					trials_in_each_bin{ibin} =  ll(ismember(ll, ul));
					% 
					% 	Get CTA running average for this bin...
					% 
                    obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					nC = nan(size(obj.ts.BinnedData.CTA{ibin}));
					nL = nan(size(obj.ts.BinnedData.LTA{ibin}));
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						if c1 < 0
							trimTS = [nan(-c1 + 1, 1); ts]; 
							nxt = [trimTS(1:c2-c1+1)]';
							nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place	
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
                        elseif c2 > numel(ts)
                            extraelements = c2 - numel(ts);
                            % trimTS = [ts; nan(extraelements, 1)];
                            % nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
                            trimTS = [ts; nan(extraelements, 1)];
                            nxt = [trimTS(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
						else
							% nxt = [ts(c1:c2) ./n]'; % keeps nan in place
							nxt = [ts(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]); % ignores the nans
							% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
						end
						%
						l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
						l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
						if l1 < 0
							trimTS = [nan(-l1 + 1, 1); ts];
							% nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
							nxt = [trimTS(1:l2-l1+1)]'; % keeps nan in place	
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        elseif l2 > numel(ts)
                            extraelements = l2 - numel(ts);
                            trimTS = [ts; nan(extraelements, 1)];
							% nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
							nxt = [trimTS(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        else
							% nxt = [ts(l1:l2)./n]'; % keeps nan in place
							nxt = [ts(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
							% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
						end
						sNc{ibin} = nC;
						sNl{ibin} = nL;
                    end
                    % figure,
                    % subplot(1,2,1)
                    % nL(isnan(nL)) = 0;
                    % nC(isnan(nC)) = 0;
                    % histogram(nC), title('number of trials per sample distribution - CTA')
                    % subplot(1,2,2)
                    % histogram(nL), title('number of trials per sample distribution - LTA')
                    
                    
% 					obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
% 					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
% 					for n = 1:numel(trials_in_each_bin{ibin})
% 						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
% 						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
% 						obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
% 
% 						l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
% 						l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
% 						obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
% 					end
					% 
					% 	Append the legend
					% 
					obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;
                
			elseif strcmpi(Mode, 'Trials')
				if verbose, disp(['Attempting to bin data with even numbers of trials... (' datestr(now,'HH:MM AM') ') \n']);, end
				% 
				% 	Divide the total number of trials into equal sized bins of trials
				% 		e.g., 5000 trials = [1:500], [501:1000], ... , [4501:5000]
				% 	We will allow the last trial bin to be smaller than the rest
				% 		*** IN THIS CASE, nbins will refer to number of TRIALS per bin
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				ntrials_per_bin = nbins;
				if strcmp(ntrials_per_bin, 'all')
					nbins = 1;
					ntrials_per_bin = obj.iv.num_trials;
					binEdges = [1,obj.iv.num_trials];
				elseif ntrials_per_bin == 1
					%  The last bin will have fewer trials
					nbins = ceil(obj.iv.num_trials/ntrials_per_bin);
					ntrials_per_bin = ntrials_per_bin;
					binEdges = 1:ntrials_per_bin:obj.iv.num_trials+1;
					if binEdges(end) ~= obj.iv.num_trials
						binEdges(end+1) = obj.iv.num_trials;
					end
				else
					%  The last bin will have fewer trials
					nbins = ceil(obj.iv.num_trials/ntrials_per_bin);
					ntrials_per_bin = ntrials_per_bin;
					binEdges = 1:ntrials_per_bin:obj.iv.num_trials;
					if binEdges(end) ~= obj.iv.num_trials
						binEdges(end+1) = obj.iv.num_trials;
					end
				end

				if verbose, disp(['nbins-CLTA: ' num2str(nbins) ' || # trials per bin (ms): ' num2str(ntrials_per_bin) ' || binEdges-CLTA: ' mat2str(binEdges) ' \n']);, end
				sNc = cell(1, nbins);
				sNl = cell(1, nbins);
				% 
				% 	Next, we will need to sort the lick times
				% 
                warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
                if numel(all_fl_wrtc_ms) > obj.iv.num_trials
                    all_fl_wrtc_ms = all_fl_wrtc_ms(1:end-1);
                end
				all_fl_wrtc_ms = [all_fl_wrtc_ms'; 1:obj.iv.num_trials];
				sorted_lt_wrtc_ms = sortrows(all_fl_wrtc_ms',1)';

				if verbose, disp(['Lick times sorted. (' datestr(now,'HH:MM AM') ') \n']);, end
				% 
				% 	Now binning is simple...
				% 		CTA 				LTA 				siITI
				% 1| 	1:500 sorted_lt	 	1:500 sorted_lt		1:500 sorted_siITI
				% 2| 	501:1000 sorted_lt	501:1000 sorted_lt	501:1000 sorted_siITI
				% ...
				% 
				trials_in_each_bin = cell(nbins, 1);
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				for ibin = 1:nbins
					if verbose && rem(ibin, nbins*.1) == 0
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					end
					trials_in_each_bin{ibin} = sorted_lt_wrtc_ms(2, binEdges(ibin):binEdges(ibin+1)-1);
					% 
					% 	Get CTA running average for this bin...
					% 
                    obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					nC = nan(size(obj.ts.BinnedData.CTA{ibin}));
					nL = nan(size(obj.ts.BinnedData.LTA{ibin}));
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						if c1 < 0
							trimTS = [nan(-c1 + 1, 1); ts]; 
							nxt = [trimTS(1:c2-c1+1)]';
							nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place	
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
                        elseif c2 > numel(ts)
                            extraelements = c2 - numel(ts);
                            % trimTS = [ts; nan(extraelements, 1)];
                            % nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
                            trimTS = [ts; nan(extraelements, 1)];
                            nxt = [trimTS(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
						else
							% nxt = [ts(c1:c2) ./n]'; % keeps nan in place
							nxt = [ts(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]); % ignores the nans
							% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
						end
						%
						l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
						l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
                        if isnan(l1) || isnan(l2)
							% if no-licks in bin, don't include the bin!
							obj.ts.BinnedData.LTA{ibin} = nan(size(obj.ts.BinnedData.LTA{ibin}));
                        elseif l1 < 0
							trimTS = [nan(-l1 + 1, 1); ts];
							% nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
							nxt = [trimTS(1:l2-l1+1)]'; % keeps nan in place	
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        elseif l2 > numel(ts)
                            extraelements = l2 - numel(ts);
                            trimTS = [ts; nan(extraelements, 1)];
							% nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
							nxt = [trimTS(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        else
							% nxt = [ts(l1:l2)./n]'; % keeps nan in place
							nxt = [ts(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
							% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
						end
						sNc{ibin} = nC;
						sNl{ibin} = nL;
                    end
                    figure,
                    subplot(1,2,1)
                    nL(isnan(nL)) = 0;
                    nC(isnan(nC)) = 0;
                    histogram(nC), title('number of trials per sample distribution - CTA')
                    subplot(1,2,2)
                    histogram(nL), title('number of trials per sample distribution - LTA')
					% obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					% obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					% for n = 1:numel(trials_in_each_bin{ibin})
					% 	c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
					% 	c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
					% 	if c1 < 0
					% 		nanpad = nan(1, -c1+1);
					% 		nxt = [nanpad'; ts(1:c2)./n]';
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
					% 	elseif c2 > numel(ts)
					% 		nanpad = nan(1, c2-numel(ts));
					% 		nxt = [ts(c1:end)./n; nanpad']';
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
					% 	else
					% 		nxt = [ts(c1:c2) ./n]';
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
					% 	end

					% 	l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
					% 	l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
					% 	if isnan(l1) || isnan(l2)
					% 		% if no-licks in bin, don't include the bin!
					% 		obj.ts.BinnedData.LTA{ibin} = nan(size(obj.ts.BinnedData.LTA{ibin}));
					% 	elseif l1 < 0
					% 		nanpad = nan(1, -l1+1);
					% 		nxt = [nanpad'; ts(1:l2)./n]';
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]);
					% 	elseif l2 > numel(ts)
					% 		nanpad = nan(1, l2-numel(ts));
					% 		nxt = [ts(l1:end)./n; nanpad']';
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]);
					% 	else
					% 		nxt = [ts(l1:l2) ./n]';
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]);
					% 	end
					% end
					% 
					% 	Append the legend
					% 
					obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((sorted_lt_wrtc_ms(1, binEdges(ibin))/1000),3)) 's - ' num2str(round((sorted_lt_wrtc_ms(1, binEdges(ibin+1)-1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = sorted_lt_wrtc_ms(1, binEdges(ibin))/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = sorted_lt_wrtc_ms(1, binEdges(ibin+1))/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = sorted_lt_wrtc_ms(1, binEdges(ibin))/1000 + (sorted_lt_wrtc_ms(1, binEdges(ibin+1))/1000 - sorted_lt_wrtc_ms(1, binEdges(ibin))/1000)/2;
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.ntrials_per_bin_CLTA = ntrials_per_bin;
                obj.ts.BinParams.nbins_CLTA = nbins;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;

            elseif strcmpi(Mode, 'overlap-loTA')
				if verbose, disp(['Attempting to bin data with overlapping-matched trial times aligned to lamp-off... (' datestr(now,'HH:MM AM') ') \n']);, end
				warning('Not for photNstim -- not normalizing # of samples')
				% 
				% 	Divide the total number of trials into equal sized bins of trials
				% 		e.g., 5000 trials = [1:500], [501:1000], ... , [4501:5000]
				% 	We will allow the last trial bin to be smaller than the rest
				% 		*** IN THIS CASE, nbins will refer to number of TRIALS per bin
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				ntrials_per_bin = nbins;
				if strcmp(ntrials_per_bin, 'all')
					nbins = 1;
					ntrials_per_bin = obj.iv.num_trials;
					binEdges = [1,obj.iv.num_trials];
				elseif ntrials_per_bin == 1
					%  The last bin will have fewer trials
					nbins = ceil(obj.iv.num_trials/ntrials_per_bin);
					ntrials_per_bin = ntrials_per_bin;
					binEdges = 1:ntrials_per_bin:obj.iv.num_trials+1;
					if binEdges(end) ~= obj.iv.num_trials
						binEdges(end+1) = obj.iv.num_trials;
					end
				else
					%  The last bin will have fewer trials
					nbins = ceil(obj.iv.num_trials/ntrials_per_bin);
					ntrials_per_bin = ntrials_per_bin;
					binEdges = 1:ntrials_per_bin:obj.iv.num_trials;
					if binEdges(end) ~= obj.iv.num_trials
						binEdges(end+1) = obj.iv.num_trials;
					end
				end

				if verbose, disp(['nbins-CLTA: ' num2str(nbins) ' || # trials per bin (ms): ' num2str(ntrials_per_bin) ' || binEdges-CLTA: ' mat2str(binEdges) ' \n']);, end
				% 
				% 	Next, we will need to sort the lick times
				% 
                warning('Binning not appropriate for 500ms rxn window (use only forced 0ms) - keep this in mind');
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
                if numel(all_fl_wrtc_ms) > obj.iv.num_trials
                    all_fl_wrtc_ms = all_fl_wrtc_ms(1:end-1);
                end
				all_fl_wrtc_ms = [all_fl_wrtc_ms'; 1:obj.iv.num_trials];
				sorted_lt_wrtc_ms = sortrows(all_fl_wrtc_ms',1)';

				if verbose, disp(['Lick times sorted. (' datestr(now,'HH:MM AM') ') \n']);, end
				% 
				% 	Now binning is simple...
				% 		CTA 				LTA 				siITI
				% 1| 	1:500 sorted_lt	 	1:500 sorted_lt		1:500 sorted_siITI
				% 2| 	501:1000 sorted_lt	501:1000 sorted_lt	501:1000 sorted_siITI
				% ...
				% 
				trials_in_each_bin = cell(nbins, 1);
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
				for ibin = 1:nbins
					if verbose && rem(ibin, nbins*.1) == 0
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					end
					trials_in_each_bin{ibin} = sorted_lt_wrtc_ms(2, binEdges(ibin):binEdges(ibin+1)-1);
					% 
					% 	Get CTA running average for this bin...
					% 
					obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						if c1 < 0
							% 
							% 	Cut out all times between lampoff-cue
							% 
							loIdx = obj.GLM.pos.lampOff(obj.GLM.pos.lampOff > 1 & obj.GLM.pos.lampOff < c2);
							cIdx = obj.GLM.pos.cue(obj.GLM.pos.cue > 1 & obj.GLM.pos.cue < c2);
							sharedIdx = [];
							lo_i = 1;
							for iIdx = 1:numel(cIdx)
								if cIdx(iIdx) < loIdx(1)
									sharedIdx = 1:cIdx(1);
									lo_i = 1;
								else
									sharedIdx = [sharedIdx, loIdx(lo_i):cIdx(iIdx)];
									lo_i = lo_i + 1;
								end
							end
							trimTS = [nan(-c1 + 1, 1); ts];
                            trimTS(sharedIdx) = [];
                            nanpad_L = nan(numel(find(sharedIdx <= obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)))) -c1+1, 1);
                            nanpad_R = nan(numel(find(sharedIdx > obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)))), 1);
							nxt = [nanpad_L; trimTS(1:c2-numel(sharedIdx)) ./n; nanpad_R]';
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
						end
						if c2 > numel(ts)
							% 
							% 	Cut out all times between lampoff-cue
							% 
							loIdx = obj.GLM.pos.lampOff(obj.GLM.pos.lampOff > c1 & obj.GLM.pos.lampOff < numel(ts));
							cIdx = obj.GLM.pos.cue(obj.GLM.pos.cue > c1 & obj.GLM.pos.cue < numel(ts));
							sharedIdx = [];
							for iIdx = 1:numel(cIdx)
								if numel(cIdx) > numel(loIdx) && iIdx == numel(cIdx)
									sharedIdx = cIdx(end):numel(ts);
								else
									sharedIdx = [sharedIdx, loIdx(iIdx):cIdx(iIdx)];
								end
							end
							trimTS = [ts; nan(c2-numel(ts), 1)];
                            trimTS(sharedIdx) = [];
                            nanpad_L = nan(numel(find(sharedIdx <= obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)))), 1);
                            nanpad_R = nan(numel(find(sharedIdx > obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)))), 1);
							nxt = [nanpad_L; trimTS(c1:end) ./n; nanpad_R]';
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
						end
						if c1 > 0 && c2 < numel(ts)
							% 
							% 	Cut out all times between lampoff-cue
							% 
							loIdx = obj.GLM.pos.lampOff(obj.GLM.pos.lampOff > c1 & obj.GLM.pos.lampOff < c2);
							cIdx = obj.GLM.pos.cue(obj.GLM.pos.cue > c1 & obj.GLM.pos.cue < c2);
							sharedIdx = [];
							lo_i = 1;
							for iIdx = 1:numel(cIdx)
								if cIdx(iIdx) < loIdx(iIdx)
									sharedIdx = 1:cIdx(1);
									lo_i = 1;
								else
									sharedIdx = [sharedIdx, loIdx(lo_i):cIdx(iIdx)];
									lo_i = lo_i + 1;
								end
                            end
							trimTS = ts;
                            trimTS(sharedIdx) = [];
                            nanpad_L = nan(numel(find(sharedIdx <= obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)))), 1);
                            nanpad_R = nan(numel(find(sharedIdx > obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)))), 1);
							nxt = [nanpad_L; trimTS(c1:c2-numel(sharedIdx)) ./n; nanpad_R]';
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
						end

						% l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
						% l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
						% if isnan(l1) || isnan(l2)
						% 	% if no-licks in bin, don't include the bin!
						% 	obj.ts.BinnedData.LTA{ibin} = nan(size(obj.ts.BinnedData.LTA{ibin}));
						% elseif l1 < 0
						% 	nanpad = nan(1, -l1+1);
						% 	nxt = [nanpad'; ts(1:l2)./n]';
						% 	obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]);
						% elseif l2 > numel(ts)
						% 	nanpad = nan(1, l2-numel(ts));
						% 	nxt = [ts(l1:end)./n; nanpad']';
						% 	obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]);
						% else
						% 	nxt = [ts(l1:l2) ./n]';
						% 	obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]);
						% end
					end
					% 
					% 	Append the legend
					% 
					obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((sorted_lt_wrtc_ms(1, binEdges(ibin))/1000),3)) 's - ' num2str(round((sorted_lt_wrtc_ms(1, binEdges(ibin+1)-1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = sorted_lt_wrtc_ms(1, binEdges(ibin))/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = sorted_lt_wrtc_ms(1, binEdges(ibin+1))/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = sorted_lt_wrtc_ms(1, binEdges(ibin))/1000 + (sorted_lt_wrtc_ms(1, binEdges(ibin+1))/1000 - sorted_lt_wrtc_ms(1, binEdges(ibin))/1000)/2;
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.ntrials_per_bin_CLTA = ntrials_per_bin;
                obj.ts.BinParams.nbins_CLTA = nbins;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;

            
			elseif strcmpi(Mode, 'Outcome')
				if verbose, disp(['Attempting to bin data by outcome... (' datestr(now,'HH:MM AM') ') \n']);, end
				% 
				% 	There will be only 6 bins - one for each category and 2 bufferzones
				% 
				if verbose, disp('Note that the reward boundary (3333ms) is not well defined, so bin 4 is 3330-3332 to avoid overlap of rew and unrewarded lost in sampling...'), end
				rxnmax = obj.Plot.wrtCue.Events.ms.rxn_time_ms;
				rxnbuffer = obj.Plot.wrtCue.Events.ms.buffer_ms+obj.Plot.wrtCue.Events.ms.rxn_time_ms;
				earlymax = obj.Plot.wrtCue.Events.ms.op_rew_open_ms - 3;
				rewbuffer = obj.Plot.wrtCue.Events.ms.op_rew_open_ms;
				rewardmax = obj.Plot.wrtCue.Events.ms.ITI_time_ms+1;
				itimax = obj.Plot.wrtCue.Events.ms.total_time_ms+1;
				binEdges = [1, rxnmax, rxnbuffer, earlymax, rewbuffer, rewardmax, itimax];
				nbins = 6;
				if verbose, disp(['nbins: ' num2str(nbins) ' || binEdges: ' mat2str(binEdges) ' \n']);, end
				sNc = cell(1, nbins);
				sNl = cell(1, nbins);
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
				% 
				% 	Find the lick times in ms wrt cue for each trial
				%
                trials_in_each_bin = cell(nbins, 1);
				for ibin = 1:nbins
					if verbose && rem(ibin, nbins*.1) == 0
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					end
					ll = find(all_fl_wrtc_ms >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
					trials_in_each_bin{ibin} =  ll(ismember(ll, ul));
					% 
					% 	Get CTA running average for this bin...
					% 
					obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					nC = nan(size(obj.ts.BinnedData.CTA{ibin}));
					nL = nan(size(obj.ts.BinnedData.LTA{ibin}));
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						if c1 < 0
							trimTS = [nan(-c1 + 1, 1); ts]; 
							nxt = [trimTS(1:c2-c1+1)]';
							nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place	
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
                        elseif c2 > numel(ts)
                            extraelements = c2 - numel(ts);
                            % trimTS = [ts; nan(extraelements, 1)];
                            % nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
                            trimTS = [ts; nan(extraelements, 1)];
                            nxt = [trimTS(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]);
						else
							% nxt = [ts(c1:c2) ./n]'; % keeps nan in place
							nxt = [ts(c1:c2)]'; % keeps nan in place	
                            nC(isnan(nC)) = 0;
							nC = nC+1;
							nC(isnan(nxt)) = nC(isnan(nxt)) - 1;
							nC(nC==0) = nan;
							nxt = nxt./nC; % keeps nan in place
							obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((nC-1)./nC); nxt]); % ignores the nans
							% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
						end
						%
						l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
						l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
						if l1 < 0
							trimTS = [nan(-l1 + 1, 1); ts];
							% nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
							nxt = [trimTS(1:l2-l1+1)]'; % keeps nan in place	
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        elseif l2 > numel(ts)
                            extraelements = l2 - numel(ts);
                            trimTS = [ts; nan(extraelements, 1)];
							% nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
							nxt = [trimTS(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
                        else
							% nxt = [ts(l1:l2)./n]'; % keeps nan in place
							nxt = [ts(l1:l2)]'; % keeps nan in place
                            nL(isnan(nL)) = 0;
							nL = nL+1;
							nL(isnan(nxt)) = nL(isnan(nxt)) - 1;
							nL(nL==0) = nan;
							nxt = nxt./nL; % keeps nan in place
							obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((nL-1)./nL); nxt]); % ignores the nans
							% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
						end
						sNc{ibin} = nC;
						sNl{ibin} = nL;
                    end
                    % figure,
                    % subplot(1,2,1)
                    % nL(isnan(nL)) = 0;
                    % nC(isnan(nC)) = 0;
                    % histogram(nC), title('number of trials per sample distribution - CTA')
                    % subplot(1,2,2)
                    % histogram(nL), title('number of trials per sample distribution - LTA')
					% for n = 1:numel(trials_in_each_bin{ibin})
					% 	c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
					% 	c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
					% 	if c1 < 0
					% 		trimTS = [nan(-c1 + 1, 1); ts];
					% 		nxt = [trimTS(1:c2-c1+1) ./n]'; % keeps nan in place	
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
     %                    elseif c2 > numel(ts)
     %                        extraelements = c2 - numel(ts);
     %                        trimTS = [ts; nan(extraelements, 1)];
     %                        nxt = [trimTS(c1:c2) ./n]'; % keeps nan in place	
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]);
					% 	else
					% 		nxt = [ts(c1:c2) ./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
					% 		% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
					% 	end
					% 	%
					% 	l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
					% 	l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
					% 	if l1 < 0
					% 		trimTS = [nan(-l1 + 1, 1); ts];
					% 		nxt = [trimTS(1:l2-l1+1)./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
     %                    elseif l2 > numel(ts)
     %                        extraelements = l2 - numel(ts);
     %                        trimTS = [ts; nan(extraelements, 1)];
					% 		nxt = [trimTS(l1:l2)./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
     %                    else
					% 		nxt = [ts(l1:l2)./n]'; % keeps nan in place
					% 		obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
					% 		% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
					% 	end
					% end
					% 
					% 	Append the legend
					% 
					obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;

            elseif strcmpi(Mode, 'OutcomeFine')
				if verbose, disp(['Attempting to bin data by outcomefine... (' datestr(now,'HH:MM AM') ') \n']);, end
				warning('Not for photNstim -- not normalizing # of samples')
				% 
				% 	There will be only 6 bins - one for each category and 2 bufferzones
				% 
				if verbose, disp('Note that the reward boundary (3333ms) is not well defined, so bin 4 is 3330-3332 to avoid overlap of rew and unrewarded lost in sampling...'), end
				rxnmax = obj.Plot.wrtCue.Events.ms.rxn_time_ms;
				rxnbuffer = obj.Plot.wrtCue.Events.ms.buffer_ms+obj.Plot.wrtCue.Events.ms.rxn_time_ms;
				earlymax = obj.Plot.wrtCue.Events.ms.op_rew_open_ms - 3;
				rewbuffer = obj.Plot.wrtCue.Events.ms.op_rew_open_ms;
				rewardmax = obj.Plot.wrtCue.Events.ms.ITI_time_ms+1;
				itimax = obj.Plot.wrtCue.Events.ms.total_time_ms+1;
				binEdges = [1, rxnmax, rxnbuffer, 1000, 2000, earlymax, rewbuffer, 5000, rewardmax, itimax];
				nbins = numel(binEdges) - 1;
				if verbose, disp(['nbins: ' num2str(nbins) ' || binEdges: ' mat2str(binEdges) ' \n']);, end
				% 
				% 	Find which trials go in each bin:
				% 		CTA 			LTA 			siITI
				% 1| 0:1s wrtCue 	0:1s wrtCue		0:1s wrtLastLick
				% 2| 1:2s wrtCue 	1:2s wrtCue		1:2s wrtLastLick
				% ...
				% 
				trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500s!!
                %
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
				% 
				% 	Find the lick times in ms wrt cue for each trial
				%
                trials_in_each_bin = cell(nbins, 1);
				for ibin = 1:nbins
					if verbose && rem(ibin, nbins*.1) == 0
						disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					end
					ll = find(all_fl_wrtc_ms >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
					trials_in_each_bin{ibin} =  ll(ismember(ll, ul));
					% 
					% 	Get CTA running average for this bin...
					% 
					obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						nxt = [ts(c1:c2) ./n]'; % keeps nan in place
						obj.ts.BinnedData.CTA{ibin} = nansum([obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
						% obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';

						l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
						l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
						nxt = [ts(l1:l2)./n]'; % keeps nan in place
						obj.ts.BinnedData.LTA{ibin} = nansum([obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n); nxt]); % ignores the nans
						% obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
					end
					% 
					% 	Append the legend
					% 
					obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;

            elseif strcmpi(Mode, 'Paired')		
				if verbose, disp(['Attempting to bin paired trials... (' datestr(now,'HH:MM AM') ') \n']); end
				if nbins{1} ~= 2
					warning('Not implemented for > 2 bins... Correcting nbins = 2')
					nbins{1} = 2;
				end

				if find(nbins{2} > 100)
					%  Data window provided in ms
					cat1_s = nbins{2}./1000;
					cat2_s = nbins{3}./1000;
					binEdges = [nbins{2}(1), nbins{2}(2), nbins{3}(1), nbins{3}(2)];
				else
					cat1_s = nbins{2};
					cat2_s = nbins{3};
					binEdges = [nbins{2}(1), nbins{2}(2), nbins{3}(1), nbins{3}(2)].*1000;
				end
			
				lTBT = nan(1, numel(obj.GLM.cue_s)); 
				lTBT(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				% 
				%	Find all trials in cat1 and cat2...	 	
				% 
				cat1Trials = find(lTBT > cat1_s(1) & lTBT < cat1_s(2));
				cat2Trials = find(lTBT > cat2_s(1) & lTBT < cat2_s(2));
				disp(['#cat1 = ' num2str(numel(cat1Trials)), ' || #cat2 = ' num2str(numel(cat2Trials))])
				% 
				% 	Find all consecutive 1->2 indicies
				% 
				consec12 = cat1Trials(find(ismember(cat1Trials,cat2Trials-1)));
				consec21 = cat2Trials(find(ismember(cat2Trials, cat1Trials-1)));
				disp(['#Consec 1->2 = ' num2str(numel(consec12)), ' || #Consec 2->1 = ' num2str(numel(consec21))])
				disp('WARNING: Method does not Bin 2->1, do this separately... 2->1 listed for comparison only.')
				trials_in_each_bin{1} = consec12;
				% bin 2 is unoccupied because is between the 2 categories. This keeps code generic between binning methods
				trials_in_each_bin{3} = consec12+1;

				figure, hold on
				plot(cat1Trials, ones(size(cat1Trials)), 'co', 'DisplayName', 'Category 1 Trials')
				plot(cat2Trials, 2*ones(size(cat2Trials)), 'go', 'DisplayName', 'Category 2 Trials')
				plot(consec12, 2*ones(size(consec12)), 'bo', 'DisplayName', 'Consecutive 1-2')
				plot(consec21, ones(size(consec21)), 'ko', 'DisplayName', 'Consecutive 2-1')
				legend();
				title('Trial Positions for Each Category in Session')
				xlabel('Trial #')
				ylabel('Trial Category')
			
					
				for ibin = 1:nbins{1}+1
					disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					if ibin == 2 % this bin should be unoccupied because it's between the two categories.
						obj.ts.BinnedData.CTA{ibin} = nan(1,2*timePad + obj.iv.total_time_ + 1);
						obj.ts.BinnedData.LTA{ibin} = nan(1,2*timePad + 1);
						% 
						% 	Append the legend
						% 
						obj.ts.BinParams.Legend_s.CLTA{ibin} = ['ntrials per bin = ', num2str(numel(consec12))];
						% 
						% 	Get Bin Time Centers and Ranges
						% 
						obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
					else
						% 
						% 	Get CTA running average for this bin...
						% 
						obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
						obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
						for n = 1:numel(trials_in_each_bin{ibin})
							c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
							c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
							obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';

							l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
							l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
							obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
						end
						% 
						% 	Append the legend
						% 
						obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
						% 
						% 	Get Bin Time Centers and Ranges
						% 
						obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
					end
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins{1}+1;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;
                % 
                % 
                % 
            elseif strcmpi(Mode, 'triplet')		
				disp(['Attempting to bin triplet trials (cat 1-1-2)... (' datestr(now,'HH:MM AM') ') \n']);
				warning('Not for photNstim -- not normalizing # of samples')
				if nbins{1} ~= 2
					warning('Not implemented for > 2 bins... Correcting nbins = 2')
					nbins{1} = 2;
				end

				if find(nbins{2} > 100)
					%  Data window provided in ms
					cat1_s = nbins{2}./1000;
					cat2_s = nbins{3}./1000;
					binEdges = [nbins{2}(1), nbins{2}(2), nbins{3}(1), nbins{3}(2)];
				else
					cat1_s = nbins{2};
					cat2_s = nbins{3};
					binEdges = [nbins{2}(1), nbins{2}(2), nbins{3}(1), nbins{3}(2)].*1000;
				end
			
				lTBT = nan(1, numel(obj.GLM.cue_s)); 
				lTBT(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				% 
				%	Find all trials in cat1 and cat2...	 	
				% 
				cat1Trials = find(lTBT > cat1_s(1) & lTBT < cat1_s(2));
				cat2Trials = find(lTBT > cat2_s(1) & lTBT < cat2_s(2));
				disp(['#cat1 = ' num2str(numel(cat1Trials)), ' || #cat2 = ' num2str(numel(cat2Trials))])
				% 
				%	Find all consecutive 1-1-2 indicies 
				% 
				consec11 = cat1Trials(find(ismember(cat1Trials,cat1Trials-1)))
				consec12 = cat1Trials(find(ismember(cat1Trials,cat2Trials-1)))
				consec112 = consec11(find(ismember(consec11,consec12-1)))
				disp(['#Consec 1->1 = ' num2str(numel(consec11)), ' || #Consec 1->2 = ' num2str(numel(consec12)), ' || #Consec 1->1->2 = ' num2str(numel(consec112))])
				trials_in_each_bin{1} = consec112+1;
				% bin 2 is unoccupied because is between the 2 categories. This keeps code generic between binning methods
				trials_in_each_bin{3} = consec112+2;

				figure, hold on
				plot(cat1Trials, ones(size(cat1Trials)), 'co', 'DisplayName', 'Category 1 Trials')
				plot(cat2Trials, 2*ones(size(cat2Trials)), 'go', 'DisplayName', 'Category 2 Trials')
				plot(consec11, 3*ones(size(consec11)), 'co', 'DisplayName', 'Consecutive 1-1')
				plot(consec12, 4*ones(size(consec12)), 'go', 'DisplayName', 'Consecutive 1-2')
				plot(consec112, 5*ones(size(consec112)), 'ko', 'DisplayName', 'Consecutive 1-1-2')
				legend();
				title('Trial Positions for Each Category in Session')
				xlabel('Trial #')
				yticks([1:5])
				yticklabels({'cat 1','cat 2','1->1','1->2','1->1->2'})
				ylabel('Trial Category')
			
					
				for ibin = 1:nbins{1}+1
					disp(['Processing bin #' num2str(ibin) '... (' datestr(now,'HH:MM AM') ')']);
					if ibin == 2 % this bin should be unoccupied because it's between the two categories.
						obj.ts.BinnedData.CTA{ibin} = nan(1,2*timePad + obj.iv.total_time_ + 1);
						obj.ts.BinnedData.LTA{ibin} = nan(1,2*timePad + 1);
						% 
						% 	Append the legend
						% 
						obj.ts.BinParams.Legend_s.CLTA{ibin} = ['ntrials per bin = ', num2str(numel(consec112))];
						% 
						% 	Get Bin Time Centers and Ranges
						% 
						obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
					else
						% 
						% 	Get CTA running average for this bin...
						% 
						obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
						obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
						for n = 1:numel(trials_in_each_bin{ibin})
							c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
							c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
							obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';

							l1 = fLick(trials_in_each_bin{ibin}(n)) - timePad;
							l2 = fLick(trials_in_each_bin{ibin}(n)) + timePad;
							obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
						end
						% 
						% 	Append the legend
						% 
						obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's | n=' num2str(numel(trials_in_each_bin{ibin}))];
						% 
						% 	Get Bin Time Centers and Ranges
						% 
						obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
					end
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins{1}+1;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;

            
            elseif strcmpi(Mode, 'Paired-nLicksBaseline')		
            	warning('Not for photNstim -- not normalizing # of samples')
				disp(['Attempting to bin paired trials by number of licks in baseline...NOT FOR RAWF!! (' datestr(now,'HH:MM AM') ') \n']);
				warning('method not for rawF!')
				if nbins{1} ~= 8
					warning('Not implemented for ~=8 bins... Correcting nbins = 8')
					nbins{1} = 8;
				end
				if numel(nbins) < 4
					nbins{4} = 5000;
				end
				baselineWindow = nbins{4};

				if find(nbins{2} > 100)
					%  Data window provided in ms
					cat1_s = nbins{2}./1000;
					cat2_s = nbins{3}./1000;
					binEdges = [nbins{2}(1), nbins{2}(2), nbins{3}(1), nbins{3}(2)];
				else
					cat1_s = nbins{2};
					cat2_s = nbins{3};
					binEdges = [nbins{2}(1), nbins{2}(2), nbins{3}(1), nbins{3}(2)].*1000;
				end
			
				lTBT = nan(1, numel(obj.GLM.cue_s)); 
				lTBT(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				% 
				%	Find all trials in cat1 and cat2...	 	
				% 
				cat1Trials = find(lTBT > cat1_s(1) & lTBT < cat1_s(2));
				cat2Trials = find(lTBT > cat2_s(1) & lTBT < cat2_s(2));
				disp(['#cat1 = ' num2str(numel(cat1Trials)), ' || #cat2 = ' num2str(numel(cat2Trials))])
				% 
				% 	Find all consecutive indicies across all categories
				%
				consec11 = cat1Trials(find(ismember(cat1Trials,cat1Trials-1)))+1; 
				consec12 = cat1Trials(find(ismember(cat1Trials,cat2Trials-1)))+1;
				consec21 = cat2Trials(find(ismember(cat2Trials, cat1Trials-1)))+1;
				consec22 = cat2Trials(find(ismember(cat2Trials, cat2Trials-1)))+1;
				% 
				% ***** INDICIES WITH RESPECT TO THE nth TRIAL!
				% 
				disp(['#Consec 1->1 = ' num2str(numel(consec11)), ' || #Consec 1->2 = ' num2str(numel(consec12)), ' || #Consec 2->1 = ' num2str(numel(consec21)), ' || #Consec 2->2 = ' num2str(numel(consec22))])
				% 
				% 	Find number of licks in baseline
				% 
				warning('baseline wrt lamp off!')
				obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff - baselineWindow + 1;
				nBaselineLicks = nan(size(obj.GLM.pos.cue));
				baselineLickTrimPos1 = nan(size(obj.GLM.pos.cue));
				baselineLickPosition = nan(size(obj.GLM.pos.cue));
				baselineLickTrimPos2 = nan(size(obj.GLM.pos.cue));
				for iTrial = 1:numel(obj.GLM.pos.cue)
					nBaselineLicks(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+baselineWindow)));
					if nBaselineLicks(iTrial) == 0
						baselineLickTrimPos1(iTrial) = -round(baselineWindow/2);
						baselineLickTrimPos2(iTrial) = round(baselineWindow/2);
						baselineLickPosition(iTrial) = obj.GLM.pos.baselineStart(iTrial) + round(baselineWindow/2);
					elseif nBaselineLicks(iTrial) == 1
						baselineLickPosition(iTrial) = obj.GLM.pos.lick(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial) & obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+baselineWindow);
						baselineLickTrimPos1(iTrial) = -(baselineLickPosition(iTrial) - obj.GLM.pos.baselineStart(iTrial));
						baselineLickTrimPos2(iTrial) = (obj.GLM.pos.baselineStart(iTrial)+baselineWindow) - baselineLickPosition(iTrial);
					end
	            end
	            % figure 
	            % bar(nBaselineLicks)
	            % xlabel('Trial #')
	            % ylabel('# licks in baseline (defined wrt lamp off)')
	            % 
	            % 	Find all trials in each nLicks category
	            % 
	            noLicksBaseline = find(nBaselineLicks == 0);
	            oneLicksBaseline = find(nBaselineLicks == 1);
	            consec11_0 = consec11(find(ismember(consec11,noLicksBaseline)));
				consec12_0 = consec12(find(ismember(consec12,noLicksBaseline)));
				consec21_0 = consec21(find(ismember(consec21,noLicksBaseline)));
				consec22_0 = consec22(find(ismember(consec22,noLicksBaseline)));
	            consec11_1 = consec11(find(ismember(consec11,oneLicksBaseline)));
				consec12_1 = consec12(find(ismember(consec12,oneLicksBaseline)));
				consec21_1 = consec21(find(ismember(consec21,oneLicksBaseline)));
				consec22_1 = consec22(find(ismember(consec22,oneLicksBaseline)));

				trials_in_each_bin{1} = consec11_0;
				trials_in_each_bin{2} = consec12_0;
				trials_in_each_bin{3} = consec21_0;
				trials_in_each_bin{4} = consec22_0;
				trials_in_each_bin{5} = consec11_1;
				trials_in_each_bin{6} = consec12_1;
				trials_in_each_bin{7} = consec21_1;
				trials_in_each_bin{8} = consec22_1;
				obj.ts.BinParams.Legend_s.CLTA{1} = ['11, Licks = 0 | ' num2str(round((nbins{2}(1)/1000),3)) 's - ' num2str(round((nbins{2}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec11_0))];
				obj.ts.BinParams.Legend_s.CLTA{2} = ['12, Licks = 0 | ' num2str(round((nbins{3}(1)/1000),3)) 's - ' num2str(round((nbins{3}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec12_0))];
				obj.ts.BinParams.Legend_s.CLTA{3} = ['21, Licks = 0 | ' num2str(round((nbins{2}(1)/1000),3)) 's - ' num2str(round((nbins{2}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec21_0))];
				obj.ts.BinParams.Legend_s.CLTA{4} = ['22, Licks = 0 | ' num2str(round((nbins{3}(1)/1000),3)) 's - ' num2str(round((nbins{3}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec22_0))];
				obj.ts.BinParams.Legend_s.CLTA{5} = ['11, Licks = 1 | ' num2str(round((nbins{2}(1)/1000),3)) 's - ' num2str(round((nbins{2}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec11_1))];
				obj.ts.BinParams.Legend_s.CLTA{6} = ['12, Licks = 1 | ' num2str(round((nbins{3}(1)/1000),3)) 's - ' num2str(round((nbins{3}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec12_1))];
				obj.ts.BinParams.Legend_s.CLTA{7} = ['21, Licks = 1 | ' num2str(round((nbins{2}(1)/1000),3)) 's - ' num2str(round((nbins{2}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec21_1))];
				obj.ts.BinParams.Legend_s.CLTA{8} = ['22, Licks = 1 | ' num2str(round((nbins{3}(1)/1000),3)) 's - ' num2str(round((nbins{3}(2)/1000),3)) 's | nTrials: ' num2str(numel(consec22_1))];
				warning('Note that LTA will be plotted relative to the lick in the baseline period! If no-lick, will plot relative to center of baseline!')

				baselines = {};

				for ibin = 1:nbins{1}
					% 
					% 	Get CTA running average for this bin...
					% 
					obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
                    warning('Need to align to the baseline lick. Stopped with editing the size of LTA, need to update the xticks and make sure indicies for LTA correct avove!')
					obj.ts.BinnedData.LTA{ibin} = nan(1,2*timePad + 1);
					for n = 1:numel(trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
						baselines{ibin}(n) = median(ts(obj.GLM.pos.lampOff(trials_in_each_bin{ibin}(n))-baselineWindow:obj.GLM.pos.lampOff(trials_in_each_bin{ibin}(n))));
						obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
						% 
						% 	Trim off the out-of-range parts of baseline
						% 
						l1 = baselineLickPosition(trials_in_each_bin{ibin}(n)) - timePad;
						l2 = baselineLickPosition(trials_in_each_bin{ibin}(n)) + timePad;
						LT = [ts(l1:l2)./n]';
						l1a = 1:timePad + baselineLickTrimPos1(trials_in_each_bin{ibin}(n));
						l2a = timePad + 1 + baselineLickTrimPos2(trials_in_each_bin{ibin}(n)):2*timePad + 1;
						LT(l1a) = nan;
						LT(l2a) = nan;
                        prev = obj.ts.BinnedData.LTA{ibin}.*((n-1)/n);
						obj.ts.BinnedData.LTA{ibin} = nansum([prev; LT],1);
					end
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					if rem(ibin,2) % if odd
						obj.ts.BinParams.s(ibin).CLTA_Min = nbins{2}(1)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Max = nbins{2}(2)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Center = nbins{2}(1)/1000 + (nbins{2}(2) - nbins{2}(1)/1000/2);
					else
						obj.ts.BinParams.s(ibin).CLTA_Min = nbins{3}(1)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Max = nbins{3}(2)/1000;
						obj.ts.BinParams.s(ibin).CLTA_Center = nbins{3}(1)/1000 + (nbins{2}(2) - nbins{3}(1)/1000/2);
					end
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins{1};
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;

                figure 
	            hold on
	            scatter3(ones(size(consec11_0)), baselines{1}, consec11_0, 15, 'filled', 'k', 'DisplayName', '11, 0 licks')
	            scatter3(3.*ones(size(consec12_0)), baselines{2}, consec12_0, 15, 'filled', 'k', 'DisplayName', '12, 0 licks')
	            scatter3(2.*ones(size(consec21_0)), baselines{3}, consec21_0, 15, 'filled', 'k', 'DisplayName', '21, 0 licks')
	            scatter3(4.*ones(size(consec22_0)), baselines{4}, consec22_0, 15, 'filled', 'k', 'DisplayName', '22, 0 licks')
	            scatter3(ones(size(consec11_1)), baselines{5}, consec11_1, 15, 'filled', 'r', 'DisplayName', '11, 1 licks')
	            scatter3(3.*ones(size(consec12_1)), baselines{6}, consec12_1, 15, 'filled', 'b', 'DisplayName', '12, 1 licks')
	            scatter3(2.*ones(size(consec21_1)), baselines{7}, consec21_1, 15, 'filled', 'g', 'DisplayName', '21, 1 licks')
	            scatter3(4.*ones(size(consec22_1)), baselines{8}, consec22_1, 15, 'filled', 'c', 'DisplayName', '22, 1 licks')
	            scatter3(1, mean(baselines{1}), mean(consec11_0), 300, 'ko', 'DisplayName', 'mean 11, 0 licks')
	            scatter3(3, mean(baselines{2}), mean(consec12_0), 300, 'ko', 'DisplayName', 'mean 12, 0 licks')
	            scatter3(2, mean(baselines{3}), mean(consec21_0), 300, 'ko', 'DisplayName', 'mean 21, 0 licks')
	            scatter3(4, mean(baselines{4}), mean(consec22_0), 300, 'ko', 'DisplayName', 'mean 22, 0 licks')
	            scatter3(1, mean(baselines{5}), mean(consec11_1), 300, 'ro', 'DisplayName', 'mean 11, 1 licks')
	            scatter3(3, mean(baselines{6}), mean(consec12_1), 300, 'bo', 'DisplayName', 'mean 12, 1 licks')
	            scatter3(2, mean(baselines{7}), mean(consec21_1), 300, 'go', 'DisplayName', 'mean 21, 1 licks')
	            scatter3(4, mean(baselines{8}), mean(consec22_1), 300, 'co', 'DisplayName', 'mean 22, 1 licks')
	            xlabel('category')
	            xticks([1,2,3,4]);
	            xticklabels({'11','21','12','22'});
	            ylabel('baseline median')
	            zlabel('trial #')
	            legend('show')



            elseif strcmpi(Mode, 'times-unbiased')	
            	warning('Not for photNstim -- not normalizing # of samples')
            	% 
            	% 	Seed rand number generator
            	% 
            	rng(1);
            	% 
            	% 	Early vs Rew ranges in ms
            	% 
            	% earlyRange = [1, 3330];
            	% rewRange = [3334, 7000];
            	% earlyRange = [700, 2000];
            	% rewRange = [2000, 3000];
            	earlyRange = [3335, 4000];
            	rewRange = [4000, 7000];
            	% 
				disp(['Attempting to bin equal time-bins in equal proportions early/late category of preceding trial... (' datestr(now,'HH:MM AM') ') \n']);
				if ~find(nbins{2} > 50)
					%  Data window provided in s
					disp('WARNING: window times for binning provided in s. Use ms! Correcting...')
					nbins{2} = nbins{2}.*1000;
				end
				% 
				% 	nbins {# of bins in range, [range to bin evenly mn, mx]}
				% 	
				% 	Gather bin edges in ms wrt cue
				% 
				if nbins{1} ~= 2 || nbins{2}(1) > 3330 || nbins{2}(2) < 3334
					time_per_bin_ms = (nbins{2}(2)-nbins{2}(1)) / nbins{1};
					binEdges = [0,0.0001,nbins{2}(1):time_per_bin_ms:nbins{2}(2),obj.iv.total_time_];
				else
					disp('*** Using Outcomes for binning ***')
					nbins{1} = nbins{1} + 1;
                    time_per_bin_ms = 'N/A';
					binEdges = [0,0.0001,nbins{2}(1),3330, 3334,nbins{2}(2),obj.iv.total_time_];
				end
				% 
				% 	bin 1 = nolick/excluded trials
				% 	bin 2 = lick time < range min (e.g., rxn)
				% 	bin 3 = lick time > range min (e.g., ITI)  
				% 
				disp(['nbins: ' num2str(nbins{1}) ' || time per bin (ms): ' num2str(time_per_bin_ms) ' || binEdges: ' mat2str(binEdges)]);
				% 
				% 	Find which trials go in each bin:
				% 
				trials_in_each_bin = {};
				trimmed_trials_in_each_bin = {};
                %
                %	Compact the f_licks into a single array for reference: ***NB there's no overlap for 0ms trials, BUT THERE WILL BE FOR 500ms!!
                %
                if obj.iv.rxnwin_ ~= 0
                	error('Binning procedure not built to handle 500ms rxn window data due to overlap of f_lick_rxn and all_ex_first_licks arrays. Can fix in another version.');
            	end
                all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
				all_fl_wrtc_ms(trialsIncluded) = obj.GLM.firstLick_s(flick_Idx) - obj.GLM.cue_s(trialsIncluded);
				all_fl_wrtc_ms = all_fl_wrtc_ms*1000;%*************ERROR CAPTURED 2/25/19 -- don't div by samples! /obj.Plot.samples_per_ms; % convert to ms
				% 
				% 	Find the lick times in ms wrt cue for each trial
				% 
                trials_in_each_bin = cell(nbins{1}+3, 1);
                nN_1Early = cell(nbins{1}+3, 1);
                nN_1Rew = cell(nbins{1}+3, 1);
                N_1Early = cell(nbins{1}+3, 1);
                N_1Rew = cell(nbins{1}+3, 1);
                % 
                % 	Start by allocating trials that fit each bin. Also find how many early and late N-1 trials are in each bin.
                % 		At the end, we will only keep a random assortment of the minimum number of early and late trials across all bins in range. 
                % 		If Bins out of range can't be corrected, we won't include them at all (e.g., nolick/excl, rxn, iti)
                % 
                for ibin = 1:nbins{1}+3
					ll = find(all_fl_wrtc_ms >= binEdges(ibin));
					ul = find(all_fl_wrtc_ms < binEdges(ibin + 1));
					trials_in_each_bin{ibin} =  ll(ismember(ll, ul));
					% 
					% 	If trial 1 is in the group, remove it because has undefined data before it...
					% 
					if ismember(1, trials_in_each_bin{ibin})
						trials_in_each_bin{ibin}(trials_in_each_bin{ibin} == 1) = [];
					end
					% 
					% 	Now find # of n-1 trials in each category
					% 
					ll = trials_in_each_bin{ibin}(all_fl_wrtc_ms(trials_in_each_bin{ibin} - 1)>=earlyRange(1));
					ul = trials_in_each_bin{ibin}(all_fl_wrtc_ms(trials_in_each_bin{ibin} - 1)<=earlyRange(2));
					N_1Early{ibin} = ll(ismember(ll, ul));
                    ll = trials_in_each_bin{ibin}(all_fl_wrtc_ms(trials_in_each_bin{ibin} - 1)>=rewRange(1));
					ul = trials_in_each_bin{ibin}(all_fl_wrtc_ms(trials_in_each_bin{ibin} - 1)<=rewRange(2));
					N_1Rew{ibin} = ll(ismember(ll, ul));
					nN_1Early{ibin} = numel(N_1Early{ibin});
					nN_1Rew{ibin} = numel(N_1Rew{ibin});
            	end
            	% 
            	% 	Find the maximum number of early and rew n-1's we can use from each bin
            	% 
            	if strcmp(time_per_bin_ms, 'N/A') % if we are binning by outcome, ignore bin 4
            		maxN_1Early = min(cell2mat(nN_1Early([3, 5:end-1])));
	            	maxN_1Rew = min(cell2mat(nN_1Rew([3, 5:end-1])));
        		else
	            	maxN_1Early = min(cell2mat(nN_1Early(3:end-1)));
	            	maxN_1Rew = min(cell2mat(nN_1Rew(3:end-1)));
            	end
            	disp(['--- # n-1 = early/bin:', num2str(maxN_1Early), ' || # n-1 = rewarded/bin:' num2str(maxN_1Rew), ' || Early Window: ', mat2str(earlyRange) ' || Rew Window: ', mat2str(rewRange)])
            	% 
            	% 	Now, go back and select a random assortment of trials that fit the bill for each bin and bin it!
            	% 
            	for ibin = 1:nbins{1}+3
            		if nN_1Early{ibin} >= maxN_1Early
	            		early2keepIdx = randperm(nN_1Early{ibin},maxN_1Early);
                    else
                        early2keepIdx = [];
        			end
            		if nN_1Rew{ibin} >= maxN_1Rew	
	            		rew2keepIdx = randperm(nN_1Rew{ibin},maxN_1Rew);
            		else
            			rew2keepIdx = [];
            		end
					trimmed_trials_in_each_bin{ibin} = [N_1Early{ibin}(early2keepIdx); N_1Rew{ibin}(rew2keepIdx)];
					% 
					% 	Get CTA running average for this bin...
					% 
					obj.ts.BinnedData.CTA{ibin} = zeros(1,2*timePad + obj.iv.total_time_ + 1);
					obj.ts.BinnedData.LTA{ibin} = zeros(1,2*timePad + 1);
					rescaleCTA = false;
					delnCTA = 0;
					for n = 1:numel(trimmed_trials_in_each_bin{ibin})
						c1 = obj.GLM.pos.cue(trimmed_trials_in_each_bin{ibin}(n)) - timePad;
						c2 = obj.GLM.pos.cue(trimmed_trials_in_each_bin{ibin}(n)) + obj.iv.total_time_ + timePad;
                        if c2 > numel(ts)
                            disp(['Ignoring a CTA trial because timePad falls off the right edge. Trial#' num2str(trimmed_trials_in_each_bin{ibin}(n)), ' Bin #' num2str(ibin)]);
                            rescaleCTA = true;
                            delnCTA = delnCTA + 1;
                        else
                            obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* ((n-1)/n) + [ts(c1:c2) ./n]';
                        end
    
    					
						l1 = fLick(trimmed_trials_in_each_bin{ibin}(n)) - timePad;
						l2 = fLick(trimmed_trials_in_each_bin{ibin}(n)) + timePad;
                        if l1 < 0 || l2 < 0 || isnan(l1) || isnan(l2)
                            obj.ts.BinnedData.LTA{ibin} = nan(size(obj.ts.BinnedData.LTA{ibin}));
                        else
    						obj.ts.BinnedData.LTA{ibin} = obj.ts.BinnedData.LTA{ibin} .* ((n-1)/n) + [ts(l1:l2)./n]';
                        end
                    end
                    warning('There''s a problem with LTA! Not indexing correctly with flick?')
					if rescaleCTA
						warning('Rescaling CTA for this bin...')
						N = numel(trimmed_trials_in_each_bin{ibin});
						obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} .* N;
						obj.ts.BinnedData.CTA{ibin} = obj.ts.BinnedData.CTA{ibin} ./ (N-delnCTA);
					end

					% 
					% 	Append the legend
					% 
					if ibin == 1
						obj.ts.BinParams.Legend_s.CLTA{ibin} = 'NoLick/Excluded Trials';
					else
						obj.ts.BinParams.Legend_s.CLTA{ibin} = [num2str(round((binEdges(ibin)/1000),3)) 's - ' num2str(round((binEdges(ibin + 1)/1000),3)) 's, N=' num2str(numel(trimmed_trials_in_each_bin{ibin}))];
					end
					% 
					% 	Get Bin Time Centers and Ranges
					% 
					obj.ts.BinParams.s(ibin).CLTA_Min = binEdges(ibin)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Max = binEdges(ibin + 1)/1000;
					obj.ts.BinParams.s(ibin).CLTA_Center = (binEdges(ibin)/1000 + (binEdges(ibin+1) - binEdges(ibin))/1000/2);
                end
                obj.ts.BinParams.binEdges_CLTA = binEdges;
                obj.ts.BinParams.trials_in_each_bin = trials_in_each_bin;
                obj.ts.BinParams.trials_in_each_bin = trimmed_trials_in_each_bin;
                obj.ts.BinParams.nbins_CLTA = nbins{1}+3;
                obj.ts.Plot.CTA.xticks.s = [-timePad:timePad+obj.iv.total_time_]/1000/samples_per_ms_xticks;
                obj.ts.Plot.LTA.xticks.s = [-timePad:timePad]/1000/samples_per_ms_xticks;
                % 
                % 	Reset RNG:
                % 
                rng('shuffle');
            end
		end


		function [results] = ANOVA(obj, groups, runANOVA, Debug)
			if nargin < 4
				Debug = false;
			end
			if nargin < 3
				runANOVA = false;
			end
			% 
			% 	Calculates compoenents for anova from groups, a cell array of listed samples. 
			% 	Thus we can put in as many samples and groups as we like
			% 
			% 	groups = (k x 1) cell array of k groups
			% 	groups{i, 1} = group i's vector of ni samples
			% 
			% 	phi is the non-centrality parameter for the F-distribution , appendix Fig B.1 in Zar
			% 		this is used to test min sample sizes and detectable differences
			% 	-- Can run without runANOVA to get the power and number of samples needed for the 
			% 		current dataset before you start hunting around for p values...
			% 
			%-----------------------------------------------------------------
			% 
			% 	Calculate size of everything
			% 
			N = numel(cell2mat(groups));
			Xmean = mean(cell2mat(groups));
			k = numel(groups);
			% 
			% 	Calculate within-group sum of squares, ss_error 
			% 	 and within group dof, dof_error
			% 	
			ss_error = sum(cell2mat(cellfun(@(x) sum((x - mean(x)).^2), groups, 'UniformOutput', 0))); 
			dof_error = N - k;
			% 
			% 	Calculate among-groups ss and dof
			% 
			ss_groups = sum(cell2mat(cellfun(@(x) numel(x)*(mean(x) - Xmean)^2, groups, 'UniformOutput', 0)));
			dof_groups = numel(groups) - 1;
			% 
			% 	All data...
			% 
			ss_total = sum(cell2mat(cellfun(@(x) sum((x - Xmean).^2), groups, 'UniformOutput', 0))); 
			dof_total = N-1;
			% 
			% check it!
			% 
			if abs(ss_total - (ss_error + ss_groups)) > 10^-6, error('sums of squares not correct'), elseif dof_total ~= dof_error + dof_groups, error('dof not correct'), end
			% 
			% 	Get variance of group, make sure isn't crazy different...
			% 
			var_ea = cellfun(@(x) var(x), groups, 'UniformOutput', 0);
			var_total = var(cell2mat(groups));
			% 
			% 	Calculate MSE's...
			% 
			MS_groups = ss_groups/dof_groups;
			MS_error = ss_error/dof_error;
			% 
			% 	Calculate phi
			% 
			phi = sqrt(((k-1)*(MS_groups)-MS_error^2)/(k*MS_error^2));
			n = [1:9:100, 200:199:1000];
			figure,
			plot(n, sqrt((2*k*MS_error^2*phi^2)./n))
			xlabel('# samples per category')
			ylabel('Minimum detectable difference')
			title(['Power level phi=' num2str(phi), ' nu1=' num2str(k-1), ' nu2=' num2str(N-k)])
			% 
			% 	Compare to MATLAB version
			% 
			% 		Make vector will all data points and group names...
			% 
			data = cell2mat(groups);
			groupName = [];
			for igroup = 1:numel(groups)
				groupName = [groupName, igroup*ones(1, numel(groups{igroup}))];
            end
            groupName = sprintfc('%d',groupName);
            if runANOVA
				[p_matlab,tbl,stats] = anova1(data, groupName);
			else
				p_matlab = NaN;
				tbl = NaN;
				stats = NaN;
			end
			% 
			% 	Return results structure:
			% 
			results.p_matlab = p_matlab;
			results.tbl = tbl;
			results.stats = stats;
			results.ss_error = ss_error;
			results.ss_groups = ss_groups;
			results.ss_total = ss_total;
			results.dof_error = dof_error;
			results.dof_groups = dof_groups;
			results.dof_total = dof_total;
			results.MS_groups = MS_groups;
			results.MS_error = MS_error;
			results.var_ea = var_ea;
			results.var_total = var_total;
			results.phi = phi;
			results.n = n;
			
		end

		function ANOVAparams = buildStaticBaselineANOVADataset(obj, baselineWindow, ts, baselineLickMode, refEvent)
			% 
			% 	Baseline window is relative to Lamp-Off here, unless specified
			% 		refEvent = 'lampOff' or 'cue'
			% 
			% 	Baseline window - : consider BEFORE event as baseline
			% 	Baseline window + : consider AFTER event as baseline
			% 
			if nargin < 5
				refEvent = 'lampOff';
			end
			if nargin < 4
				baselineLickMode = 'exclude'; %'off', 'include'
			end
			if nargin < 3
				ts = obj.GLM.gfit;
				warning('Using 200-boxcar gfit from GLM struct')
			end
			% 
			% 	We will find all trials in each 'cell' and record the mean of the baseline to the set
			% 
			% 	Factor A = (n-1 trial outcome)
			% 		level 1 = early
			% 		level 2 = rewarded
			% 
			% 	Factor B = (n trial outcome)
			% 		level 1 = early
			% 		level 2	= rewarded
			% -------------------------------------------------
        	% 
        	% 	Early vs Rew ranges in ms
        	% 
        	earlyRange = [700, 3330];
        	rewRange = [3334, 7000];
        	% earlyRange = [700, 2000];
        	% rewRange = [4000, 7000];
        	% 
            all_fl_wrtc_ms = zeros(numel(obj.GLM.lampOff_s), 1);
			all_fl_wrtc_ms(obj.GLM.fLick_trial_num) = obj.GLM.firstLick_s - obj.GLM.cue_s(obj.GLM.fLick_trial_num);
			all_fl_wrtc_ms = all_fl_wrtc_ms*1000/obj.Plot.samples_per_ms; % convert to ms
			allTrialIdx = 1:numel(all_fl_wrtc_ms);
        	% 
        	% 	We will find all trials fitting each Factor-level, then find intersections. 
        	% 	Then we will take the appropriate data from each set to make the cell-dataset
        	% 
        	ll = allTrialIdx(all_fl_wrtc_ms(1:end-1) >= earlyRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(1:end-1) <= earlyRange(2));
			A1 = ll(ismember(ll, ul));

        	ll = allTrialIdx(all_fl_wrtc_ms(1:end-1) >= rewRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(1:end-1) <= rewRange(2));
			A2 = ll(ismember(ll, ul));

        	ll = allTrialIdx(all_fl_wrtc_ms(2:end) >= earlyRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(2:end) <= earlyRange(2));
			B1 = ll(ismember(ll, ul));

        	ll = allTrialIdx(all_fl_wrtc_ms(2:end) >= rewRange(1));
			ul = allTrialIdx(all_fl_wrtc_ms(2:end) <= rewRange(2));
			B2 = ll(ismember(ll, ul));
			% NB! This is indexed as (trial n) - 1. Just for the intersections. Need to add 1 to get final trial n!
			% 
			% 	Find trial indicies for each cell.
			% 
			A1B1_idx = intersect(A1, B1) + 1;
			A2B1_idx = intersect(A2, B1) + 1;
			A1B2_idx = intersect(A1, B2) + 1;
			A2B2_idx = intersect(A2, B2) + 1;
			if isempty(A1B1_idx), error('(n-1) early (n) early factor doesn''t exist in data'),
			elseif isempty(A2B1_idx), error('(n-1) rew (n) early factor doesn''t exist in data'),
			elseif isempty(A1B2_idx), error('(n-1) early (n) rew factor doesn''t exist in data'),
			elseif isempty(A2B2_idx), error('(n-1) rew (n) rew factor doesn''t exist in data'), end
			% 
			% 	Get data for each cell:
			% 
			A_level = cell(1, numel(A1B1_idx)+numel(A2B1_idx));
			B_level = cell(1, numel(A1B1_idx)+numel(A1B2_idx));

			if strcmpi(refEvent, 'lampOff')
				if baselineWindow < 0
					A1B1 = nan(numel(A1B1_idx), 1);
					for iTrial = 1:numel(A1B1_idx)
						A1B1(iTrial) = mean(ts(obj.GLM.pos.lampOff(A1B1_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A1B1_idx(iTrial))));
						A_level{iTrial} = 'early n-1';
						B_level{iTrial} = 'early n';
					end
					A2B1 = nan(numel(A2B1_idx), 1);
					for iTrial = 1:numel(A2B1_idx)
						A2B1(iTrial) = mean(ts(obj.GLM.pos.lampOff(A2B1_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A2B1_idx(iTrial))));
						A_level{numel(A1B1_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+iTrial} = 'early n';
					end
					A1B2 = nan(numel(A1B2_idx), 1);
					for iTrial = 1:numel(A1B2_idx)
						A1B2(iTrial) = mean(ts(obj.GLM.pos.lampOff(A1B2_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A1B2_idx(iTrial))));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'early n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'rewarded n';
					end
					A2B2 = nan(numel(A2B2_idx), 1);
					for iTrial = 1:numel(A2B2_idx)
						A2B2(iTrial) = mean(ts(obj.GLM.pos.lampOff(A2B2_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A2B2_idx(iTrial))));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n';	
					end
				else
					A1B1 = nan(numel(A1B1_idx), 1);
					for iTrial = 1:numel(A1B1_idx)
						A1B1(iTrial) = mean(ts(obj.GLM.pos.lampOff(A1B1_idx(iTrial)):obj.GLM.pos.lampOff(A1B1_idx(iTrial)) + baselineWindow));
						A_level{iTrial} = 'early n-1';
						B_level{iTrial} = 'early n';
					end
					A2B1 = nan(numel(A2B1_idx), 1);
					for iTrial = 1:numel(A2B1_idx)
						A2B1(iTrial) = mean(ts(obj.GLM.pos.lampOff(A2B1_idx(iTrial)):obj.GLM.pos.lampOff(A2B1_idx(iTrial)) + baselineWindow));
						A_level{numel(A1B1_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+iTrial} = 'early n';
					end
					A1B2 = nan(numel(A1B2_idx), 1);
					for iTrial = 1:numel(A1B2_idx)
						A1B2(iTrial) = mean(ts(obj.GLM.pos.lampOff(A1B2_idx(iTrial)):obj.GLM.pos.lampOff(A1B2_idx(iTrial)) + baselineWindow));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'early n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+iTrial} = 'rewarded n';
					end
					A2B2 = nan(numel(A2B2_idx), 1);
					for iTrial = 1:numel(A2B2_idx)
						A2B2(iTrial) = mean(ts(obj.GLM.pos.lampOff(A2B2_idx(iTrial)) - abs(baselineWindow):obj.GLM.pos.lampOff(A2B2_idx(iTrial)) + baselineWindow));
						A_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n-1';
						B_level{numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+iTrial} = 'rewarded n';	
					end
				end
			elseif strcmpi(refEvent, 'cue')
				error('Not Implemented')
			else
				error('Not Implemented')
			end

			if strcmpi(baselineLickMode, 'include')
				% 
				% 	If using nLicks in baseline...
				% 
				if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'lick'), obj.GLM.pos.lick = obj.getXPositionsWRTgfit(obj.GLM.lick_s);, end
				% 
				% 	Determine the indicies of the beginnings of each baseline Period...
				% 
				if strcmpi(refEvent, 'lampOff')
					if baselineWindow < 0
						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff - abs(baselineWindow) + 1;
					else
						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff;
					end
				elseif strcmpi(refEvent, 'cue')
					error('Not Implemented')
				else
					error('Not Implemented')
				end
				obj.GLM.pos.baselineStart(end+1) = numel(obj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
				
				nBaselineLicks = zeros(size(obj.GLM.pos.cue));

				if strcmpi(refEvent, 'lampOff')
					if baselineWindow < 0
						for iTrial = 1:numel(obj.GLM.pos.cue)
							nBaselineLicks(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+abs(baselineWindow))));
	            		end
					else
						for iTrial = 1:numel(obj.GLM.pos.cue)
							nBaselineLicks(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+baselineWindow)));
	            		end
					end
				elseif strcmpi(refEvent, 'cue')
					error('Not Implemented')
				else
					error('Not Implemented')
				end
				
	            figure 
	            bar(nBaselineLicks)
	            xlabel('Trial #')
	            ylabel('# licks in baseline')

	            trialOrder = [A1B1_idx,A2B1_idx,A1B2_idx,A2B2_idx];
	            lickLevel = zeros(size(trialOrder));
	            lickLevel(find(nBaselineLicks(trialOrder) ~= 0)) = 1;
                
	            figure;
				hold on
% 				C = linspecer(max(nBaselineLicks)*2);
                C = colormap('hsv');
                C = C(1:32, :);
                colormap(C)
                maxNLicks = max(nBaselineLicks(all_fl_wrtc_ms > 700 & all_fl_wrtc_ms < 7000));
                caxis([1,maxNLicks])
%                 st = max(nBaselineLicks);
                allIdx = 1:numel(A1B1_idx);
				for iTrial = 1:numel(A1B1_idx)
					if lickLevel(allIdx(iTrial)) == ~(nBaselineLicks(A1B1_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A1B1_idx(iTrial)) > 0
						plot(1+rand(1)/3, A1B1(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :) -0, 'MarkerEdgeColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :), 'Markersize', 10);
					else
						plot(1+rand(1)/3, A1B1(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end
				plot(1, mean(A1B1), 'ko', 'MarkerSize', 30);
                allIdx = numel(A1B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx);
				for iTrial = 1:numel(A2B1_idx)
					if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B1_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A2B1_idx(iTrial)) > 0
						plot(2+rand(1)/3, A2B1(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32),:), 'Markersize', 10);
					else
						plot(2+rand(1)/3, A2B1(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end	
				plot(2, mean(A2B1), 'ko', 'MarkerSize', 30);
                allIdx = numel(A1B1_idx)+numel(A2B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx);
				for iTrial = 1:numel(A1B2_idx)
					if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A1B2_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A1B2_idx(iTrial)) > 0
						plot(3+rand(1)/3, A1B2(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32),:), 'Markersize', 10);
					else
						plot(3+rand(1)/3, A1B2(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end
				plot(3, mean(A1B2), 'ko', 'MarkerSize', 30);
				allIdx = numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+numel(A2B2_idx);
				for iTrial = 1:numel(A2B2_idx)
					if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B2_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A2B2_idx(iTrial)) > 0
						plot(4+rand(1)/3, A2B2(iTrial), 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32),:), 'Markersize', 10);
					else
						plot(4+rand(1)/3, A2B2(iTrial), 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end						
				plot(4, mean(A2B2), 'ko', 'MarkerSize', 30);
				ax = gca;
				set(ax, 'fontsize', 20);
				ax.XAxis.TickValues = [1,2,3,4];
				ax.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				% 
				% 	Run ANOVA
				% 
				ANOVAparams.earlyRange = earlyRange;
				ANOVAparams.rewRange = rewRange;
				ANOVAparams.A1 = '(n-1) early';
				ANOVAparams.A2 = '(n-1) rewarded';
				ANOVAparams.B1 = '(n) early';
				ANOVAparams.B2 = '(n) rewarded';
				ANOVAparams.L1 = 'No Baseline Licks';
				ANOVAparams.L2 = '+ Baseline Licks';
				ANOVAparams.factorIdx.A1 = A1;
				ANOVAparams.factorIdx.A2 = A2;
				ANOVAparams.factorIdx.B1 = B1;
				ANOVAparams.factorIdx.B2 = B2;
				ANOVAparams.factorIdx.nBaselineLicks = nBaselineLicks;
				ANOVAparams.cellIdx.A1B1 = A1B1_idx;
				ANOVAparams.cellIdx.A2B1 = A2B1_idx;
				ANOVAparams.cellIdx.A1B2 = A1B2_idx;
				ANOVAparams.cellIdx.A2B2 = A2B2_idx;
				ANOVAparams.cellData.A1B1 = A1B1;
				ANOVAparams.cellData.A2B1 = A2B1;
				ANOVAparams.cellData.A1B2 = A1B2;
				ANOVAparams.cellData.A2B2 = A2B2;
				ANOVAparams.cellData.A_level = A_level;
				ANOVAparams.cellData.B_level = B_level;
				ANOVAparams.cellData.lickLevel = lickLevel;
				ANOVAparams.cellData.data = [A1B1;A2B1;A1B2;A2B2];
				[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level, lickLevel}, 'model','interaction');
			elseif strcmpi(baselineLickMode, 'exclude')
				% 
				% 	If using nLicks in baseline...
				% 
				if ~isfield(obj.GLM, 'pos') || ~isfield(obj.GLM.pos, 'lick'), obj.GLM.pos.lick = obj.getXPositionsWRTgfit(obj.GLM.lick_s);, end
				% 
				% 	Determine the indicies of the beginnings of each baseline Period...
				% 
				if strcmpi(refEvent, 'lampOff')
					if baselineWindow < 0
						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff - abs(baselineWindow) + 1;
					else
						obj.GLM.pos.baselineStart = obj.GLM.pos.lampOff;
					end
				elseif strcmpi(refEvent, 'cue')
					error('Not Implemented')
				else
					error('Not Implemented')
				end
				
				obj.GLM.pos.baselineStart(end+1) = numel(obj.GLM.rawF); % tack on the full length so that we can correct the entire signal...
				
				nBaselineLicks = zeros(size(obj.GLM.pos.cue));
				for iTrial = 1:numel(obj.GLM.pos.cue)
					nBaselineLicks(iTrial) = sum(ismember(find(obj.GLM.pos.lick > obj.GLM.pos.baselineStart(iTrial)), find(obj.GLM.pos.lick < obj.GLM.pos.baselineStart(iTrial)+abs(baselineWindow))));
	            end
	            figure 
	            bar(nBaselineLicks)
	            xlabel('Trial #')
	            ylabel('# licks in baseline')
	            % 
	            %	Look at all trials
	            %
	            trialOrder = [A1B1_idx,A2B1_idx,A1B2_idx,A2B2_idx];
	            lickLevel = zeros(size(trialOrder));
	            lickLevel(find(nBaselineLicks(trialOrder) ~= 0)) = 1;
                
	            figure;
	            ax1 = subplot(1,2,1);
	            ax2 = subplot(1,2,2);
				hold(ax1, 'on');
				hold(ax2, 'on');
% 				C = linspecer(max(nBaselineLicks)*2);
                C = colormap('hsv');
                C = C(1:32, :);
                colormap(C)
                maxNLicks = max(nBaselineLicks(all_fl_wrtc_ms > 700 & all_fl_wrtc_ms < 7000));
                caxis(ax1, [1,maxNLicks])
%                 st = max(nBaselineLicks);
                allIdx = 1:numel(A1B1_idx);
                % rng(1);
				for iTrial = 1:numel(A1B1_idx)
					if lickLevel(allIdx(iTrial)) == ~(nBaselineLicks(A1B1_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A1B1_idx(iTrial)) > 0
						scatter3(ax1, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :) -0, 'MarkerEdgeColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :));
					else
						scatter3(ax1, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end
				scatter3(ax1,1, mean(A1B1), 1, 1000, 'ko', 'LineWidth', 3);
                allIdx = numel(A1B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx);
				for iTrial = 1:numel(A2B1_idx)
					if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B1_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A2B1_idx(iTrial)) > 0
						scatter3(ax1, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32),:));
					else
						scatter3(ax1, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end	
				scatter3(ax1,2, mean(A2B1), 1, 1000, 'ko', 'LineWidth', 3);
                allIdx = numel(A1B1_idx)+numel(A2B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx);
				for iTrial = 1:numel(A1B2_idx)
					if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A1B2_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A1B2_idx(iTrial)) > 0
						scatter3(ax1, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32),:));
					else
						scatter3(ax1, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end
				scatter3(ax1,3, mean(A1B2), 1, 1000, 'ko', 'LineWidth', 3);
				allIdx = numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+numel(A2B2_idx);
				for iTrial = 1:numel(A2B2_idx)
					if lickLevel(allIdx(iTrial)) ~= true(nBaselineLicks(A2B2_idx(iTrial)))
						error('Lick level is not correct!')
					end
					if nBaselineLicks(A2B2_idx(iTrial)) > 0
						scatter3(ax1, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32),:));
					else
						scatter3(ax1, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end						
				scatter3(ax1,4, mean(A2B2), 1, 1000, 'ko', 'LineWidth', 3);
				set(ax1, 'fontsize', 16);
				ax1.XAxis.TickValues = [1,2,3,4];
				ax1.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				% 
				% 	Remove trials with licks in ITI
				% 
	            A1B1(nBaselineLicks(A1B1_idx) > 0) = [];
				A2B1(nBaselineLicks(A2B1_idx) > 0) = [];
				A1B2(nBaselineLicks(A1B2_idx) > 0) = [];
				A2B2(nBaselineLicks(A2B2_idx) > 0) = [];
				A1B1_idx(nBaselineLicks(A1B1_idx) > 0) = [];
				A2B1_idx(nBaselineLicks(A2B1_idx) > 0) = [];
				A1B2_idx(nBaselineLicks(A1B2_idx) > 0) = [];
				A2B2_idx(nBaselineLicks(A2B2_idx) > 0) = [];
				A_level(nBaselineLicks(trialOrder) > 0) = [];
				B_level(nBaselineLicks(trialOrder) > 0) = [];
				trialOrder = [A1B1_idx,A2B1_idx,A1B2_idx,A2B2_idx];
				% 
				allIdx = 1:numel(A1B1_idx);
                % rng(1);
				for iTrial = 1:numel(A1B1_idx)
					if nBaselineLicks(A1B1_idx(iTrial)) > 0
						scatter3(ax2, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :) -0, 'MarkerEdgeColor', C(round(nBaselineLicks(A1B1_idx(iTrial))/maxNLicks*32), :));
					else
						scatter3(ax2, 1+rand(1)/3, A1B1(iTrial), A1B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end
				scatter3(ax2,1, mean(A1B1), 1, 1000, 'ko', 'LineWidth', 3);
                allIdx = numel(A1B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx);
				for iTrial = 1:numel(A2B1_idx)
					if nBaselineLicks(A2B1_idx(iTrial)) > 0
						scatter3(ax2, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 30, 'o', 'filled', 'MarkerFaceColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B1_idx(iTrial))/maxNLicks*32),:));
					else
						scatter3(ax2, 2+rand(1)/3, A2B1(iTrial), A2B1_idx(iTrial), 15, 'o', 'filled', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end	
				scatter3(ax2,2, mean(A2B1), 1, 1000, 'ko', 'LineWidth', 3);
                allIdx = numel(A1B1_idx)+numel(A2B1_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx);
				for iTrial = 1:numel(A1B2_idx)
					if nBaselineLicks(A1B2_idx(iTrial)) > 0
						scatter3(ax2, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A1B2_idx(iTrial))/maxNLicks*32),:));
					else
						scatter3(ax2, 3+rand(1)/3, A1B2(iTrial), A1B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end
				scatter3(ax2,3, mean(A1B2), 1, 1000, 'ko', 'LineWidth', 3);
				allIdx = numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+1:numel(A1B1_idx)+numel(A2B1_idx)+numel(A1B2_idx)+numel(A2B2_idx);
				for iTrial = 1:numel(A2B2_idx)
					if nBaselineLicks(A2B2_idx(iTrial)) > 0
						scatter3(ax2, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 30, 'o', 'MarkerFaceColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32), :), 'MarkerEdgeColor', C(round(nBaselineLicks(A2B2_idx(iTrial))/maxNLicks*32),:));
					else
						scatter3(ax2, 4+rand(1)/3, A2B2(iTrial), A2B2_idx(iTrial), 15, 'o', 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
					end
				end						
				scatter3(ax2,4, mean(A2B2), 1, 1000, 'ko', 'LineWidth', 3);
				set(ax2, 'fontsize', 16);
				ax2.XAxis.TickValues = [1,2,3,4];
				ax2.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				% 
				% 	Run ANOVA
				% 
				ANOVAparams.earlyRange = earlyRange;
				ANOVAparams.rewRange = rewRange;
				ANOVAparams.A1 = '(n-1) early';
				ANOVAparams.A2 = '(n-1) rewarded';
				ANOVAparams.B1 = '(n) early';
				ANOVAparams.B2 = '(n) rewarded';
				ANOVAparams.L1 = 'No Baseline Licks';
				ANOVAparams.L2 = '+ Baseline Licks';
				ANOVAparams.factorIdx.A1 = A1;
				ANOVAparams.factorIdx.A2 = A2;
				ANOVAparams.factorIdx.B1 = B1;
				ANOVAparams.factorIdx.B2 = B2;
				ANOVAparams.factorIdx.nBaselineLicks = nBaselineLicks;
				ANOVAparams.cellIdx.A1B1 = A1B1_idx;
				ANOVAparams.cellIdx.A2B1 = A2B1_idx;
				ANOVAparams.cellIdx.A1B2 = A1B2_idx;
				ANOVAparams.cellIdx.A2B2 = A2B2_idx;
				ANOVAparams.cellData.A1B1 = A1B1;
				ANOVAparams.cellData.A2B1 = A2B1;
				ANOVAparams.cellData.A1B2 = A1B2;
				ANOVAparams.cellData.A2B2 = A2B2;
				ANOVAparams.cellData.A_level = A_level;
				ANOVAparams.cellData.B_level = B_level;
				ANOVAparams.cellData.data = [A1B1;A2B1;A1B2;A2B2];
				[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level}, 'model','interaction');
				% rng('default');
            else
				% 
				% 	Plot the means for each cell
				% 
				figure;
				hold on
				plot(ones(numel(A1B1_idx)), A1B1, 'o');
				plot(1, mean(A1B1), 'ko', 'MarkerSize', 30);
				plot(2*ones(numel(A2B1_idx)), A2B1, 'o');
				plot(2, mean(A2B1), 'ko', 'MarkerSize', 30);
				plot(3*ones(numel(A1B2_idx)), A1B2, 'o');
				plot(3, mean(A1B2), 'ko', 'MarkerSize', 30);
				plot(4*ones(numel(A2B2)), A2B2, 'o');
				plot(4, mean(A2B2), 'ko', 'MarkerSize', 30);
				ax = gca;
				set(ax, 'fontsize', 20);
				ax.XAxis.TickValues = [1,2,3,4];
				ax.XAxis.TickLabels = {'(n-1) early|n early','(n-1) rew|n early','(n-1) early|n rew','(n-1) rew|n rew'};
				% 
				% 	Run ANOVA
				% 
				ANOVAparams.earlyRange = earlyRange;
				ANOVAparams.rewRange = rewRange;
				ANOVAparams.A1 = '(n-1) early';
				ANOVAparams.A2 = '(n-1) rewarded';
				ANOVAparams.B1 = '(n) early';
				ANOVAparams.B2 = '(n) rewarded';
				ANOVAparams.factorIdx.A1 = A1;
				ANOVAparams.factorIdx.A2 = A2;
				ANOVAparams.factorIdx.B1 = B1;
				ANOVAparams.factorIdx.B2 = B2;
				ANOVAparams.cellIdx.A1B1 = A1B1_idx;
				ANOVAparams.cellIdx.A2B1 = A2B1_idx;
				ANOVAparams.cellIdx.A1B2 = A1B2_idx;
				ANOVAparams.cellIdx.A2B2 = A2B2_idx;
				ANOVAparams.cellData.A1B1 = A1B1;
				ANOVAparams.cellData.A2B1 = A2B1;
				ANOVAparams.cellData.A1B2 = A1B2;
				ANOVAparams.cellData.A2B2 = A2B2;
				ANOVAparams.cellData.A_level = A_level;
				ANOVAparams.cellData.B_level = B_level;
				ANOVAparams.cellData.data = [A1B1;A2B1;A1B2;A2B2];
				[ANOVAparams.results.p,ANOVAparams.results.tbl,ANOVAparams.results.stats,ANOVAparams.results.terms] = anovan(ANOVAparams.cellData.data, {A_level, B_level}, 'model','interaction');
			end
			% 
			% 	Calculate expected power of test for dataset
			% 
			% k_prime = 2; % number of levels of each factor
			% n_primeA = numel(A1B1_idx) + numel(A2B1_idx);
			% ssA = 
			% phiA = sqrt()
		end

		function redoNMBgfitChR2(obj, ntrials)
			if nargin < 2
				ntrials = 10;
			end
			if ~isfield(obj.GLM, 'rawF'), obj.loadRawF, end
            if ~isfield(obj.GLM, 'ChR2values')
                obj.GLM.pos.ChR2 = [];
            else
                obj.GLM.pos.ChR2 = find(obj.GLM.ChR2values > 2);
                uptimesright = obj.GLM.pos.ChR2 + 2;
                uptimesleft = obj.GLM.pos.ChR2 - 2;
                obj.GLM.pos.ChR2 = unique(horzcat(obj.GLM.pos.ChR2, uptimesright, uptimesleft));
            end
			% 
			%	Chop out the ChR2 times from the fluorescence signal
			% 
			obj.GLM.rawFchop = obj.GLM.rawF;
			obj.GLM.rawFchop(obj.GLM.pos.ChR2) = nan;
			% 
			% 	Execute fast gfit (10-trial baseline), which will keep nans as nans and we won't have to worry about them.
			% 
            obj.GLM.isSingleSeshObj = true;
			obj.GLM.gfit = obj.normalizedMultiBaselineDFF(5000, 10, obj.GLM.rawFchop);
			obj.GLM.gfitMode = [num2str(ntrials), 'trial norm multi baseline'];
		end


		function progressBar(obj, iter, total, nested, cutter)
			if nargin < 5
				cutter = 1000;
			end
			if nargin < 4
				nested = false;
			end
			if nested
				prefix = '		';
			else
				prefix = '';
			end
			if rem(iter,total*.1) == 0 || rem(iter, cutter) == 0
				done = {'=', '=', '=', '=', '=', '=', '=', '=', '=', '='};
				incomplete = {'-', '-', '-', '-', '-', '-', '-', '-', '-', '-'};
				ndone = round(iter/total * 10);
				nincomp = round((1 - iter/total) * 10);
				disp([prefix '	*' horzcat(done{1:ndone}) horzcat(incomplete{1:nincomp}) '	(' num2str(iter) '/' num2str(total) ') ' datestr(now)]);
			end
		end


		function gfitderivative = gfitCamera(obj, CamOtimes, IRtrig, Mode, iter, usePreprocessed)
			Debug = 1;
			% NEW We can now run in M_JPEG mode for multiple video files... 
			% 		Set Mode  = M_JPEG
			% 		iter = 1
			% 	Then will recursively run this function to create the gfit
			if nargin < 4
				% 
				% 	The default mode is the original video format, in which there is only 1 video per CED session.
				% 
				Mode = 'M_JPEG';
				% Mode = 'default';
			end
			if nargin < 5
				% 
				% 	If we are looping through videos in the video folder, we will specify the iter in the loop - this will let us concatenate video file gfits
				% 
				% 	We probably also want to save the first CED CamO spike for each video file
				% 
				iter = 1;
			end
			if nargin < 6
				% 
				% 	Assume we will not use preprocessed
				% 
				usePreprocessed = 0;
			end
			% 
			% 	Preprocess AVI files
			% 
			if strcmpi(Mode, 'M_JPEG') && ~usePreprocessed
				% 
				% 	The M-JPEG format forces us to divide the file into multiple .AVI files of size 330 MB each. 
				% 	Thus, on first iter we have to initiate the video iteration process, and then on subsequent iters, 
				% 	we will append the remaining videos to our video structure in the object.
				% 
				% 	Also, since this video format is new, we will also save the CamO stamps for each first frame in each 
				% 	video in the folder so we can eventually go back and do this more simply in the future.
				% 
				if iter == 1
					% 
					% 	Initialize the derivative signal
					% 
					obj.video.derivativeSignal = [];
					obj.video.Version = datestr(now,'mm_dd_yy__HH_MM_AM');
					obj.video.saveDir = pwd;
					% 
					% 	Make a directory to store the video_structs we are making for debug
					% 
					hostFolder = uigetdir('','Select .avi VIDEO host folder - if want to use preprocessed, hit cancel');
					if ~hostFolder
						usePreprocessed = 1;
						% 
						% 	Choose the pre-processed video folder
						% 
						preprocessedFolder = uigetdir('','Choose the pre-processed video folder');
						if ~preprocessedFolder
							usePreprocessed = 0;
							warning('Cancelled video selection')
							return
						end
						cd(preprocessedFolder)	
						thisDir = pwd;
						obj.video.videoDir = thisDir;
						dirFiles = dir(thisDir);
						dirFiles = dirFiles(~[dirFiles.isdir]);
						dirFiles = dirFiles(contains({dirFiles.name}, '.avi'));
						obj.video.nVideos = length(dirFiles);				
						if Debug
							disp('Selected a pre-processed video folder.')
						end
						
					else
						usePreprocessed = 0;
						cd(hostFolder)					
						if Debug
							obj.video.video_struct_dirname = [hostFolder '\Debug_video_structs_' obj.video.Version];
						else
							obj.video.video_struct_dirname = [hostFolder '\video_structs_' obj.video.Version];
						end
						mkdir(obj.video.video_struct_dirname);
						% 
						% 	Here, we select the folder with the videos for this CED file
						% 
						thisDir = pwd;
						obj.video.videoDir = thisDir;
						dirFiles = dir(thisDir);
						dirFiles = dirFiles(~[dirFiles.isdir]);
						dirFiles = dirFiles(contains({dirFiles.name}, '.avi'));
						obj.video.nVideos = length(dirFiles);
						% 
						% 	Catch the current video:
						% 		by definition, iter should be 1 for the first video in the folder...
						% 
						thisFile = dirFiles(iter).name;
						video_struct.init_variables.AVI_file_address = [thisDir, '\', thisFile];
						video_struct.video_obj = VideoReader(video_struct.init_variables.AVI_file_address);
						%
						vidWidth = video_struct.video_obj.Height;
						vidHeight = video_struct.video_obj.Width;
						beginTime = 0; % use this to rewind the readFrame fx
						% 
						% 	Store that video file in the host folder!
						% 
						obj.iv.videoFolder = hostFolder;
						% 
						% 	1. Find the position of the trigger and save the idx to the obj
						%
						obj.video.note{1,1} = 'IRtrigPos: Position of the IR trig wrt CamO index in CED file';
						video_struct.frame1CEDPosition = find(CamOtimes > IRtrig, 1);
						obj.video.IRtrigPos = video_struct.frame1CEDPosition;

						obj.video.note{2,1} = 'fileCamOidx: this is the position in CamO that each video file starts';
						obj.video.fileCamOidx(iter) = 1;
						% 
						% 	2. Trim the CED strobe times so the frame times match those saved in trimmed video file
						% 
						video_struct.cedFrameTimes = CamOtimes(obj.video.IRtrigPos:end);
						
						% 
						%	3. Find the IR trigger frame, from which everything else will be referenced
						% 
						video_struct = findTriggerFrame(obj, video_struct, beginTime);
						obj.video.note{4,1} = '.file1sync.frame = IR trigger frame (exp start sync) for file 1; .file1sync.time = IR trigger time (exp start sync) for file 1; nframes = the total nframes in the 1st video, not wrt CED';
						obj.video.file1sync.frame = video_struct.synced_exp_frame_1.frame;
						obj.video.file1sync.time = video_struct.synced_exp_frame_1.time;
						% 
						% 	Set the video file start time:
						% 
						start_time = obj.video.file1sync.time;
					end
				else
					% 
					% 	Return to the video folder and pick out the next video in the iteration, then append the gfit
					% 
					cd(obj.video.videoDir)
					% 
					% 	Get the directory name
					% 
					thisDir = pwd;
					% 
					% 	Get the names of the video files
					% 
					dirFiles = dir(thisDir);
					dirFiles = dirFiles(~[dirFiles.isdir]);
					dirFiles = dirFiles(contains({dirFiles.name}, '.avi'));
					% 
					% 	Catch the current video using the iter number (iter should be >1 in theory unless rewritting video)
					% 
					if iter == 1
						error('Warning, you''re iter==1, so you''ll rewrite the video!');
					end
					thisFile = dirFiles(iter).name;
					video_struct.init_variables.AVI_file_address = [thisDir, '\' thisFile];
					video_struct.video_obj = VideoReader(video_struct.init_variables.AVI_file_address);
					%
					vidWidth = video_struct.video_obj.Height;
					vidHeight = video_struct.video_obj.Width;
					beginTime = 0; % use this to rewind the readFrame fx
					% 
					% 	Now, update the indicies
					% 
					obj.video.fileCamOidx(iter) = obj.video.fileCamOidx(iter-1) + obj.video.fileCamO_nFrames(iter-1);
					% 
					% 	Set the video file start time, which should be zero if we are not on iter 1!
					% 
					start_time = 0;
					video_struct.synced_exp_frame_1.time = start_time;
				end
				if ~usePreprocessed
					% 
					% 	Let us know how we're doing...
					% 
					obj.progressBar(iter, obj.video.nVideos, 0, 10);
					% 
					% 	Regardless of iteration....
					% 
					% 
					%  	4. Calculate the difference signal
					% 
					video_struct = obj.cameraDifferenceSignal(video_struct, start_time, iter);
					% 
					% 		For debug purposes, find out how many frames are in this video. 
					% 		The next video should have its CED CamO frame start on the next CamO strobe
					% 
					obj.video.note{3,1} = 'fileCamO_nFrames: WRT IRtrigger tells us how many frames should be in each video so we can check CamO idxs -- full length of file 1 is in obj.video.file1sync.nframesTotal';
					obj.video.fileCamO_nFrames(iter) = video_struct.total_frames;
					% 
					% 	Note, we need to update the file's total and relative nframes for indexing wrt IRtrigger
					% 
					if iter == 1
						warning('RBF - check indexing')
						obj.video.file1sync.nframesTotal = obj.video.fileCamO_nFrames(iter);
						obj.video.fileCamO_nFrames(iter) = obj.video.fileCamO_nFrames(iter) - obj.video.file1sync.frame;
					end
					% 
					% 	If this is the last video in the folder, tell us we're finally done.
					% 
					if iter == length(dirFiles)
						c = clock;
						disp(['Difference signals ALL complete at ' num2str(c(4)) ':' num2str(c(5)) '.'])
					end
					% 
					%	4. Rewind the video to the first frame on the CED:
					% 
					video_struct.video_obj.CurrentTime = video_struct.synced_exp_frame_1.time; % resets frames to frame 1-aligned to CED
					% 
					% 	Save the processed .AVI files
					% 
					gfitderivative = video_struct.derivativeSignal;
					% cd(obj.video.saveDir)
					cd(obj.video.video_struct_dirname)
					if Debug % save everything	
						processed_AVI_filename = [num2str(iter) '_video_struct.mat'];
						save(processed_AVI_filename, 'video_struct', '-v7.3');
						% disp(['Processed AVI files saved (' processed_AVI_filename ')'])
					else % save the gfit
						% processed_AVI_filename = [num2str(iter) '_derivativeSignal.mat'];
						% save(processed_AVI_filename, 'gfitderivative', '-v7.3');
					end
					% 
					% 	Remember to move back to the original directory
					% 
					cd ..
					% 
					% 	Append the gfit to the video field
					% 
					obj.video.derivativeSignal(end+1:end+numel(gfitderivative)) = gfitderivative;
					% 
					% 	Finally, return this guy!
					% 
					gfitderivative = obj.video.derivativeSignal;
					% 
					%	Now, call the next iter if necessary: 
					% 
					if iter < obj.video.nVideos
						gfitderivative = obj.gfitCamera(CamOtimes, IRtrig, Mode, iter+1);
					end
					if Debug
						disp(['Closing iter ' num2str(iter)])
					end
					% 
					% 
					% 
				end
			elseif strcmpi(Mode, 'M_JPEG') && usePreprocessed
					% 'proceed'
			else % for LEGACY video (before August 2019, single .AVI file per CED file)
				% 
				% 1. CED preparation----------------------------------------------------------------------
				% 
				% 	First Extract the CED IR trigger timepoint and strobe timepoints - these are passed in as arguments (CamOtimes and IRtrig)
				%
				% 2. Trim the CED camera frame timestamps-------------------------------------------------
				% 
				% 	1. Find the position of the trigger:
				% 
				video_struct.frame1CEDPosition = find(CamOtimes > IRtrig, 1);
				% 
				% 	2. Trim the CED strobe times so the frame times match those saved in trimmed video file
				% 
				video_struct.cedFrameTimes = CamOtimes(video_struct.frame1CEDPosition:end);
				% 
				% 3. Video preparation--------------------------------------------------------------------
				% 
				% 	1. Collect UI for the video to analyze:
				% 
				[FileName,PathName,~]= uigetfile('./*.avi', 'Select video to analyze...');
				video_struct.init_variables.AVI_file_address = [PathName, FileName];
				video_struct.video_obj = VideoReader(video_struct.init_variables.AVI_file_address);
				%
				vidWidth = video_struct.video_obj.Height;
				vidHeight = video_struct.video_obj.Width;
				beginTime = 0; % use this to rewind the readFrame fx
				% 
			    % 
				%% 4. and 5. Identify the trigger zone with the first video image and Find Trigger Frame---
				% 
				video_struct = obj.findTriggerFrame(video_struct, beginTime);
				% 
				%% 6. Calculate the difference signal------------------------------------------------------
				% 
				video_struct = obj.cameraDifferenceSignal(video_struct, video_struct.synced_exp_frame_1.time);
				% 
				%	7. Rewind the video to the first frame on the CED:
				% 
				video_struct.video_obj.CurrentTime = video_struct.synced_exp_frame_1.time; % resets frames to frame 1-aligned to CED
				% 
				% 	Save the processed .AVI files
				% 
				disp('Saving processed .AVI files')
				timestamp_now = datestr(now,'mm_dd_yy__HH_MM_AM');
				processed_AVI_filename = ['CamO_processed_' obj.iv.mousename_ '_day' obj.iv.daynum_ '_' timestamp_now];
				save(processed_AVI_filename, 'video_struct', '-v7.3');
				disp('Processed AVI files saved (CamO_processed_...)')
				disp(' ')
				% 
				% 	Add variables to object in useful way:
				% 
				gfitderivative = video_struct.derivativeSignal;
			end


			% 
			% 	Now, if using preprocessed:
			% 
			if strcmpi(Mode, 'M_JPEG') && usePreprocessed
				% 
				% 	Let us know how we're doing...
				% 
				obj.progressBar(iter, obj.video.nVideos, 0, 10);
				% 
				% 	Regardless of iteration....
				% 
				thisDir = pwd;
				obj.video.videoDir = thisDir;
				dirFiles = dir(thisDir);
				dirFiles = dirFiles(~[dirFiles.isdir]);
				dirFiles = dirFiles(contains({dirFiles.name}, '.mat'));
				obj.video.nVideos = length(dirFiles);
				% 
				%  	4. Load the video struct and pluck off the derivative signal
				% 
				thisFile = dirFiles(iter).name;
				file_address = [thisDir, '\', thisFile];
				load(file_address);
				obj.video.derivativeSignal(end+1:end+length(video_struct.derivativeSignal)) = video_struct.derivativeSignal;

				if iter == 1
					obj.video.note{2,1} = 'fileCamOidx: this is the position in CamO that each video file starts';
					obj.video.fileCamOidx(iter) = 1;
					obj.video.note{1,1} = 'IRtrigPos: Position of the IR trig wrt CamO index in CED file';
					obj.video.IRtrigPos = video_struct.frame1CEDPosition;
					obj.video.note{4,1} = '.file1sync.frame = IR trigger frame (exp start sync) for file 1; .file1sync.time = IR trigger time (exp start sync) for file 1; nframes = the total nframes in the 1st video, not wrt CED';
					obj.video.file1sync.frame = video_struct.synced_exp_frame_1.frame;
					obj.video.file1sync.time = video_struct.synced_exp_frame_1.time;
					obj.video.note{3,1} = 'fileCamO_nFrames: WRT IRtrigger tells us how many frames should be in each video so we can check CamO idxs -- full length of file 1 is in obj.video.file1sync.nframesTotal';
					obj.video.fileCamO_nFrames(iter) = video_struct.total_frames;
					% 
					% 	Note, we need to update the file's total and relative nframes for indexing wrt IRtrigger
					% 
					warning('RBF - check indexing')
					obj.video.file1sync.nframesTotal = obj.video.fileCamO_nFrames(iter) + video_struct.synced_exp_frame_1.frame;
					% obj.video.fileCamO_nFrames(iter) = obj.video.fileCamO_nFrames(iter) - obj.video.file1sync.frame;

				else
					obj.video.fileCamO_nFrames(iter) = video_struct.total_frames;
					obj.video.fileCamOidx(iter) = obj.video.fileCamOidx(iter-1) + obj.video.fileCamO_nFrames(iter-1);
				end
				% 
				% 	If this is the last video in the folder, tell us we're finally done.
				% 
				if iter == length(dirFiles)
					c = clock;
					disp(['Difference signals ALL complete at ' num2str(c(4)) ':' num2str(c(5)) '.'])
				end
				
				if iter < obj.video.nVideos
					obj.gfitCamera(CamOtimes, IRtrig, Mode, iter+1, 1);
				end
				if Debug
					disp(['Closing iter ' num2str(iter)])
				end
				% 
			end
			if iter == 1
				% 
				% 	Return to the original directory and save the final gfit
				% 
				cd obj.video.saveDir
                gfitderivative = obj.video.derivativeSignal;
				save(['AbsCamODerivative_v3x9_' obj.video.Version '.mat'], 'gfitderivative', '-v7.3');
			end
		end

		function video_struct = findTriggerFrame(obj, video_struct, beginTime)
			% 
			%% 4. Identify the trigger zone with the first video image:--------------------------------
			% 
			% 	1. Collect first recorded image:
			% 
			video_struct.video_obj.CurrentTime = beginTime; % resets frames to init
			video_struct.first_camera_shot = readFrame(video_struct.video_obj);
			%
			% 	2. UI select rectangle for the Trigger Zone
			% 
			figure
			getTrigImage = video_struct.first_camera_shot;
			imshow(getTrigImage)
			title('Select Trigger Zone')
			rect = getrect(gca);
			% find midpoint:
			xmin_ = rect(1);
			ymin_ = rect(2);
			width_ = rect(3);
			height_ = rect(4);
			triggerPoint.yTrigger = round(xmin_ + 0.5*(width_));
			triggerPoint.xTrigger = round(ymin_ + 0.5*(height_));
			drawTriggerZone = insertObjectAnnotation(getTrigImage,'rectangle',rect,'Trigger Zone','LineWidth',3,'Color',{'red'},'TextColor','white');
			drawTriggerZone = insertObjectAnnotation(drawTriggerZone,'circle',[triggerPoint.yTrigger, triggerPoint.xTrigger, 1],['Trigger Point: ' num2str(triggerPoint.yTrigger) ',' num2str(triggerPoint.xTrigger)],'LineWidth',3,'Color',{'cyan'},'TextColor','black');
			imshow(drawTriggerZone)
			% 
			%% 5. Find Trigger Frame ------------------------------------------------------------------
			% 
			%  1. Look at each frame and determine when Trigger Zone pixel goes dark
			% 
			disp('Looking for trigger image transition....')
			video_struct.video_obj.CurrentTime = beginTime; % resets frames to init
			triggerFrameFound = false;
			currentFrame = 1;
			video_struct.IRPixelValues = [];
			currentTime = [];
			% 
			while ~triggerFrameFound
				currentTime(currentFrame) = video_struct.video_obj.CurrentTime;
				thisFrame = readFrame(video_struct.video_obj);
				video_struct.IRPixelValues(currentFrame) = thisFrame(triggerPoint.xTrigger,triggerPoint.yTrigger,1);
				%
				if video_struct.IRPixelValues(currentFrame) < 210
					% this is the first frame after trigger!
					triggerFrameFound = true;		
					video_struct.synced_exp_frame_1.frame = currentFrame;
					video_struct.synced_exp_frame_1.time = video_struct.video_obj.CurrentTime;
				else
					% keep looking!
					currentFrame = currentFrame + 1;
				end
			end
			disp(['Found trigger transition at camera frame ' num2str(currentFrame) '.'])
			figure
			title('Transition Point')
			subplot(1,2,2)
			imshow(thisFrame)
			title('First Frame wrt CED')
			% 
			video_struct.video_obj.CurrentTime = currentTime(currentFrame-1);
			pastFrame = readFrame(video_struct.video_obj);
			subplot(1,2,1)
			imshow(pastFrame)
			title('Last Frame before Trigger')
		end


		function video_struct = cameraDifferenceSignal(obj, video_struct, video_start_time, iter)
			% 
			%% 6. Calculate the difference signal for camera data
			% 
			% -----------------------------------------------------------------------------------------
			if nargin < 4
				iter = 1;
			end
			if iter ~= 1
				% 	NOTE: for 1st file (IRtrig-contianing), video_start_time = video_struct.synced_exp_frame_1.time; Otherwise is time 0;
				assert(video_start_time == 0)
			else
				% 
				%	0. Grab current time so you can keep track of how long this takes... 
				% 
				c = clock;
				disp(['Calculating difference signals... Start: ' num2str(c(4)) ':' num2str(c(5)) '. Please wait...'])
			end
			% 
			%	1. Rewind the video to the first frame on the CED:
			% 
			video_struct.video_obj.CurrentTime = video_start_time; % resets frames to frame 1-aligned to CED
			% 
			% 	If iter == 1, assign the ref image to the obj
			% 
			if iter == 1
				% 
				% 	2. Assign reference image:
				% 
				video_struct.reference = readFrame(video_struct.video_obj);
				video_struct.reference = video_struct.reference(:,:,1);
				video_struct.video_obj.CurrentTime = video_start_time; % resets frames to frame 1-aligned to CED
				 
				obj.video.reference = video_struct.reference;
			end
			% 
			%   3. Calculate each difference image and then get the 1D rep of that, add it to the difference array. So we won't save the difference images...
			% 
			video_struct.differenceSignal = [];
			% 
			% 			Iterate over all frames!
			% 
			vidWidth = video_struct.video_obj.Height; % these are backwards on purpose
			vidHeight = video_struct.video_obj.Width;
			% 
			max_frame_difference = 255*vidHeight*vidWidth;
			current_frame = 1;
			% 
			% 	3A. We will also calculate a running derivative. Thus, keep the sum of all the frames in an array, which we can keep and mess with later
			% 
			video_struct.frame_sum = sum(sum(obj.video.reference));	% Note: first sum is the reference image, so elements 1 and 2 are the same
			video_struct.derivativeSignal = [];							% (frame_sum(frame# + 1) - frame_sum(frame#) - because frame_sum is one frame ahead of current frame
			% 
			while hasFrame(video_struct.video_obj)
				% 
				% 	Capture this frame
				% 
			    thisFrame 		= readFrame(video_struct.video_obj);
			    video_struct.frame_sum(current_frame + 1) = sum(sum(thisFrame(:,:,1)));
			    % 
			    % 	Calculate running difference (percent change)
			    % 
			    differenceFrame = thisFrame(:,:,1) - obj.video.reference;
			    difference_1D   = sum(sum(differenceFrame(:,:,1)))/max_frame_difference * 100;
			    video_struct.differenceSignal(current_frame) = difference_1D;
			    % 
			    % 	Calculate running derivative (percent change)
			    % 
			    video_struct.derivativeSignal(current_frame) = (video_struct.frame_sum(current_frame + 1) - video_struct.frame_sum(current_frame))/max_frame_difference * 100;
			    % 
			    % 	Advance to next frame
			    % 
			    current_frame = current_frame + 1;
			end
			% 
			% 	Finally, store the total number of frames
			% 
			% 
			% 	5. Get total number of frames
			% 
			video_struct.total_frames = current_frame-1;


		end


		function alignedTS = aveAlignedTStoTimestamps(obj, ts, stamps, nSamples, stampsMultiplier)
			% 
			% 	Here we can take any timeseries, ts, and align it to any timestamp (stamps = in samples)
			% 		We return the average of the aligned data (calculated as a running average) with number 
			% 		of samples on EITHER side of event = nSamples
			% 
            if nargin < 5
                stampsMultiplier = 1;
%             else you should use the 1/(ctrl sampling rate) =
%             1/(2*obj.Plot.samples_per_ms)
            end
			if nargin < 4
				nSamples = 10000;
			end
			if nargin < 3
				stamps = 'X';
			end
			if strcmp(stamps, 'EMG')
				% 
				% 	Use thresholded EMG or X data
				% 
				if isfield(obj.GLM.EMG)
					disp('Using EMG as ts. Rectifying now...')
					obj.GLM.EMG = abs(obj.GLM.EMG);
					stamps = find(obj.GLM.EMG(2:end) > 2*std(obj.GLM.EMG));
				else
					error('EMG not present in Obj')
				end
				% 
				% 	Need to downsample:
				% 
				stamps = round(stamps.*stampsMultiplier);
				stampID = 'EMG';
				% 
			elseif strcmp(stamps, 'X')
				if isfield(obj.GLM.X)
					disp('Using X as ts...')
					if mean(obj.GLM.X) > 0.1
						disp('	Bandpassing and rectifying raw X...')
						obj.GLM.X = abs(obj.bandPass(obj.GLM.X));
					end
					stamps = find(obj.GLM.X(2:end) > 3*std(obj.GLM.X));
				else
					error('X not present in Obj')
				end
				% 
				% 	Need to downsample:
				% 
				stamps = round(stamps.*stampsMultiplier);
				stampID = 'X';
			else
				stampID = 'UI-defined timestamps';
                stamps = round(stamps.*stampsMultiplier);
			end
			if nargin < 2
				disp('Using gfit in Obj as the ts...')
				ts = obj.GLM.gfit;
				tsname = obj.GLM.gfitStyle;
			else
				tsname = 'UI-defined ts';
			end

			% 
			% 	Initialize alignment vector:
			% 
			alignedTS = nan(1, 2*nSamples+1);
			% 
			% 	For each timestamp, align the ts, extract the points, add to the running mean...
			% 
			for n = 1:numel(stamps)
				c1 = stamps(n) - nSamples;
				c2 = stamps(n) + nSamples;
				if c1 <= 0
					nxt = [nan(1, -c1+1), ts(1:c2)'];
				elseif c2 > numel(ts)
					nxt = [ts(c1:end)', nan(1,c2-numel(ts))];
				else
					nxt = ts(c1:c2)';
				end
				alignedTS = nansum([alignedTS .* ((n-1)/n); nxt ./n]);
			end

				
			figure
			plot([-nSamples:nSamples], alignedTS)
			xlabel('Samples wrt Alignment Event')
			ylabel('Signal amplitude')
			title(['Ave ' tsname ' aligned to ' stampID])
		end


		function [trimTS, trimIdxs_choptime, trimIdxs_originaltime] = trimTSbyLOItoLick(obj, ts, Hz)
			% 
			% 	trimTS is the chop/concat version of the timeseries from Lamp-off to first lick
			% 	trimIdxs is the indicies of the trimmed data samples wrt the original ts 
			% 		(so for EMG, must downsample first to get aligned correctly, then to get back to real time, must double the number of samples)
			% 		we will keep both chop time and original time as options for debug (3/15/19)
			% 	NOTE NEEDS ADDITIONAL WORK FOR CAMO POTENTIALLY!
			% 	
			if nargin < 3
				disp('Using default sampling rate in obj.Plot.samples_per_ms')
				Hz = obj.Plot.samples_per_ms;
			end
			if nargin < 2
				disp('Using gfit stored in obj.GLM.gfit')
				ts = obj.GLM.gfit;
			end
			if round(Hz) == 2
				%  downsample the EMG/X data
				ts = ts(1:2:end);
				smoothing = 0;
			else
				smoothing = obj.Plot.smooth_kernel;
			end
			debugOn = true;
			% 
			% 	Get rid of any trials longer than 7 sec...
			% 
			samples_per_ms = obj.Plot.samples_per_ms;
			obj.GLM.pos.flick = obj.getXPositionsWRTgfit(obj.GLM.firstLick_s);
            if ~isfield(obj.GLM, 'cue')
                cue = obj.GLM.cue_s;
            else
                cue = obj.GLM.cue;
            end
			obj.GLM.pos.cue = round(1000*cue*samples_per_ms);
            obj.GLM.pos.fLick = round(1000*obj.GLM.firstLick_s*samples_per_ms);
            obj.GLM.pos.flick = obj.GLM.pos.fLick;
            obj.GLM.pos.lampOff = round(1000*obj.GLM.lampOff_s*samples_per_ms);
			% 
			% 	All trials with a lick...
			% 
			trialpool = obj.GLM.fLick_trial_num;
			
			nTrials = numel(trialpool);
			
			SnfLickIdx = 1:nTrials;
			SnTrials = trialpool(SnfLickIdx);
			

			obj.GLM.pos.pos1 = 1;
			obj.GLM.pos.pos2 = numel(ts);
			ts_sm = obj.smooth(ts, smoothing);
			% 
			% 	Trim off any > 7s trials
			% 
			% disp('*** Selecting only trials with length 0:7s ***')
			binWindows = [0,7]; % previously [1,2,3,4,5,6,7]
			if isfield(obj.GLM, 'uniformTrialNums')
				obj.GLM.uniformTrialNums = [];
			end
			lick_tbt_trim_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(SnTrials), obj.GLM.pos.flick(SnfLickIdx), 'UniformOutput', 0)); 
			[N,edges, Bin] = histcounts(lick_tbt_trim_s,binWindows);
            % debug:
% 			figure, subplot(1,3,1), histogram(lick_tbt_trim_s, [0,7,17]), title('Distribution of Lick Times Overall')
			% 
			% 	Select only trials in bin #1
			% 
			SnfLickIdxTrim = find(Bin == 1);
% 			subplot(1,3,2), histogram(lick_tbt_trim_s(SnfLickIdxTrim), [0,7,17]), title('Distribution of Lick Times in Selected Trials')
			SnTrialsTrim = trialpool(SnfLickIdxTrim);
			% 
			% 	Now select only the correct trials
			% 
			% [tstrim,t,t_times, obj.GLM.flush.idx_b_t, obj.GLM.flush.idxcat] = obj.trial2lickTrim(SnTrialsTrim, SnfLickIdxTrim);
			
			trials = SnTrialsTrim;
			flickIdx = SnfLickIdxTrim;

			idx_b_t = arrayfun(@(lo, lick) lo:lick, obj.GLM.pos.lampOff(trials), obj.GLM.pos.flick(flickIdx), 'UniformOutput', 0);
            idxcat = [];
            for idx = 1:numel(idx_b_t)
                idxcat = horzcat(idxcat, idx_b_t{idx, 1});
            end
            % 
            %   Collect variables
            % 
            trimTS = ts_sm(idxcat);
            t = numel(idxcat);
            trimIdxs_choptime = idxcat;
            if round(Hz) == 2
				%  need to upsample the trimIdxs to get back in real time
				trimIdxs_originaltime = trimIdxs_choptime + trimIdxs_choptime-1;
			else
				trimIdxs_originaltime = trimIdxs_choptime;
			end
            % 
			lick_tbt_trim_uniform_s = cell2mat(arrayfun(@(cue, lick) (lick-cue)/1000/samples_per_ms, obj.GLM.pos.cue(SnTrialsTrim), obj.GLM.pos.flick(SnfLickIdxTrim), 'UniformOutput', 0)); 
% 			subplot(1,3,3), histogram(lick_tbt_trim_uniform_s, binWindows), title('Distribution of Lick Times in Sn post selection operation')	
			% 
		end

		function getTSkernel(obj, STDmult, kernelSig, gfitSig)
			% 
			% 	Use this to define the kernel of a movement signal spike onto arbitrary signal (like gfit) with varying STD-multiplier
			% 		Using for Movement signal building for nestedGLM 3/15/19
			% 	Note, not ok to use for CamO - sampling rate is off
			% 
			if nargin < 4
				[trimTS, ~] = obj.trimTSbyLOItoLick(); % uses stored gfit
				gfitSigName = 'gfit';
			else
				warning('not tested! RBF')
				[trimTS, ~] = obj.trimTSbyLOItoLick(gfitSig); 
				gfitSigName = 'UI-defined signal';
			end
			if nargin < 3
				kernelSig = abs(obj.GLM.EMG);
				kernelSigName = 'abs-EMG';
			else
				kernelSigName = 'UI-defined control signal';
			end
			if nargin < 2
				STDmult = 5;
				disp('Using STD multiplier of 5')
			end

			
			figure, plot(trimTS), title(['Trimmed ' gfitSigName ' from LO->flick'])
			ax1 = gca;
			[trimEMG, trimIdxs_choptime, trimIdxs_originaltime] = obj.trimTSbyLOItoLick(kernelSig, 2*obj.Plot.samples_per_ms); % note: this is for photometry signal object
			figure, plot(trimEMG), title(['Trimmed stamp Sig ' kernelSigName ' from LO->flick'])
			ax2 = gca;
			linkaxes([ax1, ax2], 'x') % to compare the phot to move signals after chop

			aboveTEMGtrim = find(trimEMG(2:end) > STDmult*std(trimEMG)); % these stamps are in trim-samples. So take the trimIdxs_choptime(aboveTEMGtrim) to get real time gfit indicies

			realtimeGfitIdxs = trimIdxs_choptime(aboveTEMGtrim);
			realtimeEMGIdxs = trimIdxs_originaltime(aboveTEMGtrim);

			aboveTEMGall = find(kernelSig(2:end) > STDmult*std(kernelSig));
			aboveTEMGall = round(aboveTEMGall/2);
			figure, plot(obj.GLM.gfit), hold on, plot(aboveTEMGall, mean(obj.GLM.gfit).*ones(size(aboveTEMGall)), 'k*', 'DisplayName', 'allspikes'), plot(realtimeGfitIdxs, mean(obj.GLM.gfit).*ones(size(realtimeGfitIdxs)), 'ro', 'DisplayName', 'LO-flick-spikes')
			plot(obj.GLM.pos.lampOff, mean(kernelSig).*ones(size(obj.GLM.pos.lampOff)), 'c*', 'displayname', 'lamp Off')
			plot(obj.GLM.pos.cue, mean(kernelSig).*ones(size(obj.GLM.pos.cue)), 'g*', 'displayname', 'cue')
			plot(obj.GLM.pos.flick, mean(kernelSig).*ones(size(obj.GLM.pos.flick)), 'm*', 'displayname', 'flick')
			ax3 = gca;
			title([gfitSigName ' with event stamps'])


			figure, plot(0.5:0.5:numel(kernelSig)/2, kernelSig), hold on, plot(aboveTEMGall, mean(kernelSig).*ones(size(aboveTEMGall.*2)), 'k*', 'displayname', 'allspikes'), plot(realtimeEMGIdxs./2, mean(kernelSig).*ones(size(realtimeEMGIdxs)), 'ro', 'displayname', 'trialint spikes')
			plot(obj.GLM.pos.lampOff, mean(kernelSig).*ones(size(obj.GLM.pos.lampOff)), 'c*', 'displayname', 'lamp Off')
			plot(obj.GLM.pos.cue, mean(kernelSig).*ones(size(obj.GLM.pos.cue)), 'g*', 'displayname', 'cue')
			plot(obj.GLM.pos.flick, mean(kernelSig).*ones(size(obj.GLM.pos.flick)), 'm*', 'displayname', 'flick')
			ax4 = gca;
			title(['stamp signal: ' kernelSigName ' with event stamps'])
			linkaxes([ax3, ax4], 'x')
			legend('show')

			obj.aveAlignedTStoTimestamps(obj.GLM.gfit, realtimeGfitIdxs, 20000, 1);
			% obj.aveAlignedTStoTimestamps(obj.GLM.gfit, realtimeGfitIdxs, 20000, 1/(2*obj.Plot.samples_per_ms));
			ax5 = gca;
			title(ax5, [gfitSigName ' aligned to ' kernelSigName ' stamps, thresh=' num2str(STDmult) 'STD'])
			obj.aveAlignedTStoTimestamps(kernelSig, realtimeEMGIdxs, 20000);
			ax6 = gca;
			title(ax6, [kernelSigName ' aligned to ' kernelSigName ' stamps, thresh=' num2str(STDmult) 'STD'])
			linkaxes([ax5, ax6], 'x')

		end

		function savegfit(obj)
			% 
			%  saves gfit in the GLM struct to a file for reuse
			% 
			if ~isfield(obj.GLM, 'gfit')
				error('No gfit stored in obj')
			end
			gfit_struct = {};
			gfit_struct.gfit_signal = obj.GLM.gfit;
			if strcmpi(obj.GLM.gfitMode, 'box200000')
				gfit_struct.gfit_window = 200000;
			else
				gfit_struct.gfit_window = [];
			end
			save(['gfit.mat'], 'gfit_struct', '-v7.3');
		end

		function [originalFlick, originalflickTrialIdx, originalPosFlick] = redoExclusions(obj, originalFlick, originalflickTrialIdx)
			if nargin < 2
				originalFlick = obj.GLM.firstLick_s;
			end
			if nargin < 3
				originalflickTrialIdx = obj.GLM.fLick_trial_num;
			end
			exc = ismember(originalflickTrialIdx, obj.iv.exclusions_struct.Excluded_Trials);
			obj.GLM.firstLick_s(exc) = [];
			obj.GLM.fLick_trial_num(exc) = [];
            obj.GLM.pos.flick(exc) = [];
		end
		function undoExclusions(obj, originalFlick, originalflickTrialIdx, originalPosFlick)
			obj.GLM.firstLick_s = originalFlick;
			obj.GLM.fLick_trial_num = originalflickTrialIdx;
            obj.GLM.pos.flick = originalPosFlick;
		end
		% REMINDER TO ADD METHOD TO TAKE EXCLUSIONS ON SINGLE-SESH TRIAL DATA...
	end
end




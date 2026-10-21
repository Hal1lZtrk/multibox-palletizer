
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
									//######### INITIALIZATIONS #################//	 
	IF (OperationType = INIT) THEN
		SignalManagement (OperationType := INIT);
		SignalManagement (OperationType := START_CONFIGURATION); 
		SignalManagement.OperationType := CONFIGURATION;
//		OperationType := RUN;
	ELSE
		SignalManagement (OperationType := START_GENERATION); 
		SignalManagement.OperationType := GENERATION;

		IF COUNT_CARTBOARD_NUMBER = 1 THEN
			boxcrane_Cartboard_ALMOST_FINISH := TRUE;
		ELSE
			boxcrane_Cartboard_ALMOST_FINISH := FALSE;
		END_IF; 
		SignalManagement
			(SignalType := WARNING,
			SignalCode := ID_Cartboard_ALMOST_FINISH,	
		SignalOutput := NONE OR MATERIALS_RUN_OUT_LAMP OR NONE,
		ActivationSignal := boxcrane_Cartboard_ALMOST_FINISH);
		IF COUNT_CARTBOARD_NUMBER = 0 THEN
			boxcrane_Cartboard_FINISH := TRUE;
		END_IF; 
		SignalManagement
			(SignalType := ALARM OR AUTO_CONDITIONED_RESET,
			SignalCode := ID_Cartboard_FINISH,	
		SignalOutput := ON_PHASE_STOP OR NONE OR NONE,
		ActivationSignal := boxcrane_Cartboard_FINISH);
	

		//######### HANDLING SIGNAL OF PALLET #################//
		IF COUNT_PALLET_NUMBER = 1 THEN
			pallet_lifter_ALMOST_FINISH := TRUE;
		ELSE
			pallet_lifter_ALMOST_FINISH := FALSE;
		END_IF; 
		SignalManagement
			(SignalType := WARNING,
			SignalCode := ID_P_lifter_ALMOST_FINISH,	
		SignalOutput := NONE OR MATERIALS_RUN_OUT_LAMP OR NONE,
		ActivationSignal := pallet_lifter_ALMOST_FINISH);
		
		IF COUNT_PALLET_NUMBER =0 THEN
			pallet_lifter_FINISH := TRUE;
		END_IF; 
		
		SignalManagement
			(SignalType := ALARM OR AUTO_CONDITIONED_RESET,
			SignalCode := ID_pallet_lifter_FINISH,
		SignalOutput := ON_PHASE_STOP OR NONE OR NONE,
		ActivationSignal := pallet_lifter_FINISH);
	
		//######### BUTTON HANDLING SIGNALS #################//
		//EMERGENCY STOP
		SignalManagement
			(SignalType := ALARM,
			SignalCode := ID_EMERGENCY_STOP,	
		SignalOutput := EMERGENCY_STOP OR NONE OR NONE,
		ActivationSignal := BUTTON_EMERGENCY_STOP);
	
		//IMMEDIATE STOP
		SignalManagement
			(SignalType := ALARM,
			SignalCode := ID_IMMEDIATE_STOP,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := BUTTON_IMMEDIATE_STOP);
	
		// ON PHASE STOP
		SignalManagement
			(SignalType := ALARM,
			SignalCode := ID_ON_PHASE_STOP,	
		SignalOutput := ON_PHASE_STOP OR NONE OR NONE,
		ActivationSignal := BUTTON_ON_PHASE_STOP);


		//######### FEEDER HANDLING SIGNALS #################//

		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_CONVEYOR_IF_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := CONVEYOR_IF_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_PUSHER_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := PUSHER_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_TURNPUSHER_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := TURNPUSHER_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_CONVEYOR_TURN1_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := CONVEYOR_TURN1_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_CONVEYOR_END_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := CONVEYOR_END_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_CARRIAGE_2_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := CARRIAGE_2_FAULT);
		//######### CRANE HANDLING SIGNALS #################//
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_CARTBORAD_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := CARTBORAD_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_VACUUM_BOX_CRANE_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := VACUUM_BOX_CRANE_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_BOX_CRANE_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := BOX_CRANE_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_GANTRY_CRANE_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := GANTRY_CRANE_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_SLIDE_RAIL_RIGHT_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := SLIDE_RAIL_RIGHT_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_PUSHER_X_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := PUSHER_X_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_PUSHER_Z_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := PUSHER_Z_FAULT);
	
							//######### PALLET HANDLING SIGNALS #################//
		IF PALLET_CONVEYOR_1_FAULT THEN
			coutn := coutn + 1;
		END_IF;
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_PALLET_CONVEYOR_1_FAULT,
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := PALLET_CONVEYOR_1_FAULT );
	
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_PALLET_CONVEYOR_2_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := PALLET_CONVEYOR_2_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_PALLET_LIFTER_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := PALLET_LIFTER_FAULT);
	
		SignalManagement
		(SignalType := ALARM OR AUX_RESET,
		SignalCode := ID_PALLET_FORK_FAULT,	
		SignalOutput := IMMEDIATE_STOP OR NONE OR NONE,
		ActivationSignal := PALLET_FORK_FAULT);	
		
		
		
			
										//######### HANDLING SIGNAL OF CARTBOARD #################//
		

	END_IF;
	

	//######### OUTPUT HANDLING SIGNALS #################//
	CheckOperationSignals := SignalManagement.SignalOutputs;	
	CathegorySIMSignalCode := SignalManagement.MySignalCode;
	Activate_signal			:= SignalManagement.ActiveSignalCodes;
	
	
	
	//######### VISUALISATION HANDLING SIGNALS GENRATION #################//	
	IF (OperationType = RUN) THEN
		SignalManagement (OperationType := RUN); (* outputs selection *)
	END_IF;
	
	
	

	//############ PRIORYTY MANAGEMENT OF SIGNALS ##################### //
	SM_EMERGENCY_STOP := ((CheckOperationSignals AND EMERGENCY_STOP) = EMERGENCY_STOP);
	
	IF SM_EMERGENCY_STOP  THEN
		SM_IMMEDIATE_STOP		:= FALSE;
		SM_IMMEDIATE_STOP_CAT1	:= FALSE;
		SM_IMMEDIATE_STOP_CAT2	:= FALSE;
		SM_IMMEDIATE_STOP_CAT3	:= FALSE;
		SM_ON_PHASE_STOP 		:= FALSE;
		blink_emergencvy_stop 	:= NOT blink_emergencvy_stop;
	END_IF;
	
	IF NOT SM_EMERGENCY_STOP  THEN
		blink_emergencvy_stop 	:= FALSE;
		IF CathegorySIMSignalCode = 2 THEN	
			blink_immediate_stop 	:= NOT blink_immediate_stop;
			
			SM_IMMEDIATE_STOP := ((CheckOperationSignals AND IMMEDIATE_STOP) = IMMEDIATE_STOP);
			SM_IMMEDIATE_STOP_CAT1	:= FALSE;
		END_IF;
		IF  CathegorySIMSignalCode>3 AND CathegorySIMSignalCode<=20 AND NOT SM_IMMEDIATE_STOP THEN	
			blink_immediate_stop 	:= NOT blink_immediate_stop;
			SM_IMMEDIATE_STOP_CAT1  := ((CheckOperationSignals AND IMMEDIATE_STOP) = IMMEDIATE_STOP);
		END_IF;

		IF SM_IMMEDIATE_STOP_CAT1 OR SM_IMMEDIATE_STOP THEN
			SM_ON_PHASE_STOP	:= FALSE;
			SM_ON_PHASE_STOP_CAT1	:= FALSE;
			SM_ON_PHASE_STOP_CAT2	:= FALSE;
		END_IF;	
	END_IF;
	
	IF NOT SM_IMMEDIATE_STOP_CAT1 AND  NOT SM_IMMEDIATE_STOP  THEN
		blink_immediate_stop 	:= FALSE;
		IF (CathegorySIMSignalCode =3) THEN
			blink_OnPhase_stop 	:= NOT blink_OnPhase_stop;
			SM_ON_PHASE_STOP  := ((CheckOperationSignals AND ON_PHASE_STOP) = ON_PHASE_STOP);
			SM_ON_PHASE_STOP_CAT1	:= FALSE;
		END_IF
		IF  (CathegorySIMSignalCode =22) AND NOT SM_ON_PHASE_STOP  THEN
			blink_OnPhase_stop 	:= NOT blink_OnPhase_stop;
			SM_ON_PHASE_STOP_CAT1  := ((CheckOperationSignals AND ON_PHASE_STOP) = ON_PHASE_STOP);
		END_IF;
		IF NOT SM_ON_PHASE_STOP_CAT1 AND NOT SM_ON_PHASE_STOP THEN
			blink_OnPhase_stop 	:= FALSE;
		END_IF;
	END_IF;


	
		
	LED_MATERIALS_RUN_OUT	:= ((CheckOperationSignals AND MATERIALS_RUN_OUT_LAMP) = MATERIALS_RUN_OUT_LAMP);
	
	LED_ALARM_INFORMATION := SignalManagement.LedSignalInformation;
	LED_ALARM_ANOMALY := SignalManagement.LedSignalAnomaly;	
	LED_ALARM_ALARM := SignalManagement.LedSignalAlarm ;
	LED_ALARM_WARNING := SignalManagement.LedSignalWarning;
	IF pallet_lifter_ALMOST_FINISH OR boxcrane_Cartboard_ALMOST_FINISH THEN
		blink_out_of_material:=TRUE;
	ELSE
		blink_out_of_material:=FALSE;	
	END_IF;

END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM



PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	 
	
	
	CASE State_Master OF
		
		Initialization:
				
  			POWER_ON_FEEDER			:= TRUE;
			POWER_ON_CRANE			:= TRUE;
			POWER_ON_PALLET			:= TRUE;
			BUTTON_START			:= FALSE;
			blink_start				:= FALSE;
			
			BUTTON_STOP				:= FALSE;
			blink_stop				:= FALSE;
			
			BUTTON_EMERGENCY_STOP	:= FALSE;
			blink_ermergency		:= FALSE;
			
			
			BUTTON_IMMEDIATE_STOP	:= FALSE;
			blink_immediatestop		:= FALSE;
			
			
			BUTTON_ON_PHASE_STOP	:= FALSE;
			blink_onphasestop		:= FALSE;
			
			BUTTON_INITIALIZATION	:= FALSE;
			blink_Fauld				:= FALSE;
			
			State_Master			:= WaitButtonStart;

			
		WaitButtonStart:
			
			IF BUTTON_START THEN
				OperationType		:= 1;
				blink_start			:= TRUE;
				blink_stop			:= TRUE;
				PalletOnPhaseStop	:= FALSE;
				CardboardOnPhaseStop	:= FALSE;
				CRANE_ON_PHASE_STOP_WAIT := FALSE;
				PALLET_ON_PHASE_STOP_WAIT	:= FALSE;
				FEEDER_ON_PHASE_STOP_WAIT 	:= FALSE;
				IF NOT AfterOnPhase THEN
					START_FEEDER		:= TRUE;
					START_CRANE			:= TRUE;
					START_PALLET		:= TRUE;
					AfterOnPhase		:= FALSE;
				END_IF;
				State_Master		:= WaitCheckHandlersStart;	
			END_IF;
			
		WaitCheckHandlersStart:
			
			IF NOT START_FEEDER AND NOT START_CRANE AND NOT START_PALLET  THEN
				
				State_Master		:= WaitFeederFeedback;	
			END_IF;

		WaitFeederFeedback:
			
			IF FEERDER_WAIT_TO_DELIVER_BOXES THEN
				Onelayeroperation		:=1;
				State_Master			:= WaitCraneFeedback;
			END_IF;
			
		WaitCraneFeedback:
			IF  (CRANE_WAIT_BOXES AND Onelayeroperation = 1) THEN
				
				IF CardboardOnPhaseStop THEN
					FEEDER_ON_PHASE_STOP			:= TRUE;
					CRANE_ON_PHASE_STOP				:= TRUE;
					State_Master		:= WaitOnphaseStop;
				END_IF;
				
				State_Master			:= WaitPalletFeedback;

			END_IF;
		WaitPalletFeedback:
			IF PALLET_WAIT_BOXES THEN
				IF Onelayeroperation = 1 THEN
					Carriage_start_moving			:= TRUE;
					
					FEERDER_WAIT_TO_DELIVER_BOXES	:= FALSE;
					State_Master					:= WaitFeederFeedback2;
				END_IF;	
			END_IF;	
			
			
		WaitFeederFeedback2:	
			IF FEERDER_BOXES_DELIVERED AND NOT START_AGAIN_FEEDER THEN
				Carriage_start_moving		:= TRUE;
				START_AGAIN_FEEDER		:=TRUE;
				FEERDER_BOXES_DELIVERED	:=FALSE;
				Onelayeroperation 		:= 2;
				State_Master			:= WaitCraneFeedback2;
			END_IF;
			
			
	
		WaitCraneFeedback2:
			IF  (CRANE_WAIT_BOXES AND Onelayeroperation = 2) THEN
				
				IF Onelayeroperation = 2 THEN
					CRANE_WAIT_BOXES	:= FALSE;//there are boxes go next
				END_IF;
				CRANE_WAIT_BOXES	:= FALSE;//moi new
				IF CardboardOnPhaseStop THEN
					FEEDER_ON_PHASE_STOP			:= TRUE;
					CRANE_ON_PHASE_STOP				:= TRUE;
					State_Master		:= WaitOnphaseStop;
				END_IF;	
				State_Master			:= WaitPalletFeedback2;
			END_IF;
			
	
			
			
		WaitPalletFeedback2:	
			IF PALLET_WAIT_BOXES THEN
				IF Onelayeroperation = 2 AND CRANE_BOXES_DELIVERED THEN

					TwolayerOperation				:= TwolayerOperation + 1;
					IF TwolayerOperation = 2 THEN					
						PALLET_WAIT_BOXES				:= FALSE;
						TwolayerOperation				:= TwolayerOperation - 2;
					END_IF;
					CRANE_BOXES_DELIVERED			:= FALSE;
					Onelayeroperation 				:= 0;
					State_Master					:= WaitFeederFeedback;
				END_IF;
				
			END_IF;
		WaitOnphaseStop:
			
			IF  PALLET_WAIT_BOXES AND CardboardOnPhaseStop AND TwolayerOperation = 2 THEN
	  			CRANE_BOXES_DELIVERED			:= FALSE;
				PALLET_WAIT_BOXES				:= FALSE;
				PALLET_ON_PHASE_STOP_REMOVE		:= FALSE;
				State_Master			:= WaitButtonStart;
			END_IF;
			BUTTON_START 			:=FALSE;
			State_Master			:= WaitButtonStart;
			
						

		WaitStopSequence:
			BUTTON_STOP	:= FALSE;
			BUTTON_START :=FALSE;
			FEEDER_STOP	:= TRUE;
			CRANE_STOP	:= TRUE;
			PALLET_STOP	:= TRUE;
			State_Master			:= Initialization;	


	
	END_CASE;
		
	IF BUTTON_STOP THEN
		FEEDER_IMMEDIATE_STOP	:= TRUE;
		CRANE_IMMEDIATE_STOP	:= TRUE;
		PALLET_IMMEDIATE_STOP	:= TRUE;
		
		State_Master			:= WaitStopSequence;
	END_IF;
	// DIRECT COMMAND OF STOP
	IF SM_EMERGENCY_STOP THEN
 		FEEDER_EMERGENCY_STOP	:= TRUE;
		CRANE_EMERGENCY_STOP	:= TRUE;
		PALLET_EMERGENCY_STOP	:= TRUE;
		BUTTON_START 			:=FALSE;
		State_Master			:= Initialization;
	END_IF;	
	
	IF SM_IMMEDIATE_STOP THEN
		FEEDER_IMMEDIATE_STOP	:= TRUE;
		CRANE_IMMEDIATE_STOP	:= TRUE;
		PALLET_IMMEDIATE_STOP	:= TRUE;
		BUTTON_START 			:=FALSE;
		State_Master					:= WaitButtonStart;
	END_IF;	
	
	IF SM_ON_PHASE_STOP THEN
		FEEDER_ON_PHASE_STOP			:= TRUE;
		CRANE_ON_PHASE_STOP				:= TRUE;
		PALLET_ON_PHASE_STOP			:= TRUE;
		PALLET_ON_PHASE_STOP_IDLE		:= TRUE;
		BUTTON_START 					:= FALSE;
		AfterOnPhase					:= TRUE;
		State_Master					:= WaitButtonStart;
	END_IF;	
	
	
	IF SM_IMMEDIATE_STOP_CAT1 THEN
		FEEDER_IMMEDIATE_STOP	:= TRUE;
		IF FEERDER_WAIT_TO_DELIVER_BOXES THEN
			CRANE_IMMEDIATE_STOP	:= TRUE;
		ELSE
			CRANE_ON_PHASE_STOP				:= TRUE;
		END_IF;
		PALLET_ON_PHASE_STOP			:= TRUE;
		BUTTON_START 					:=FALSE;
		State_Master					:= WaitButtonStart;
	END_IF;	
	
	IF SM_ON_PHASE_STOP_CAT1 THEN
		BUTTON_START 			:=FALSE;
		CardboardOnPhaseStop	:= TRUE;
	END_IF;		

END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM



PROGRAM _INIT
	(* Insert code here *)
	Carriage_2_target_position_array[0]:=0.44;
	Carriage_2_target_position_array[1]:=1.1;
	Carriage_2_target_position_array[2]:=0.9;
	index:=0;
	CountPusherState	:= 8;
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	 
	CASE State_Feeder OF
		WaitPowerON:
			IF POWER_ON_FEEDER THEN
			conveyor_if_disable_request	:= TRUE;
			conveyor_turn1_disable_request	:= TRUE;
			conveyor_end_disable_request	:= TRUE;
			carriage_2.PowerON				:=TRUE;
			State_Feeder							:=WaitStart;				
			END_IF;

		WaitStart:
			IF (START_FEEDER) THEN
				conveyor_if_enable_request	:=TRUE;
				conveyor_end_enable_request	:=TRUE;
				conveyor_turn1_enable_request	:=TRUE;
				IF carriage_2.Powered THEN
					START_FEEDER				:= FALSE;
					POWER_ON_FEEDER 			:= FALSE;
					State_Feeder						:= WaitConveyorEnabled;
				END_IF;
			END_IF;
		WaitConveyorEnabled:
			
			IF NOT conveyor_if_enable_request AND NOT conveyor_end_enable_request AND NOT conveyor_turn1_enable_request THEN

				State_Feeder	:= WaitSensorBox;
			END_IF;
			
		WaitSensorBox:
			
			IF LASER_SENSOR_IR  THEN
//				LASER_SENSOR_IR_MEM	:= FALSE;
				COUNT_LASER_SENSOR_IR:=COUNT_LASER_SENSOR_IR+1;
				State_Feeder	:= WaitpusherenableStop;
			END_IF;
			
		WaitpusherenableStop:

			IF NOT WaitCarriage AND NOT FIRST_LAYER_OPERATION THEN
				
				IF NUM_BOX_COUNTED<=7 THEN
					pusher_enable_request	:= TRUE;
					State_Feeder	:= WaitPusherStop;
				END_IF;

				IF NUM_BOX_COUNTED=8 THEN
					pusher_enable_request	:= TRUE;
					FIRST_LAYER_OPERATION		:=TRUE;
					NUM_BOX_COUNTED :=0;
					State_Feeder	:= WaitPusherStop;
				END_IF;
  			END_IF;
			IF NOT WaitCarriage AND FIRST_LAYER_OPERATION THEN
				IF NUM_BOX_COUNTED<=5 THEN
					pusher_enable_request	:= TRUE;
					State_Feeder	:= WaitPusherStop;
						
				END_IF;
					
				IF NUM_BOX_COUNTED=6 THEN
					pusher_enable_request	:= TRUE;
					State_Feeder	:= WaitPusherStop;		
				END_IF;
			END_IF;


		WaitPusherStop:
			IF ( NOT pusher_enable_request) THEN
				pusher_disable_request	:= TRUE;
				State_Feeder	:= WaitSensorCount;		
					
			END_IF;
			
		WaitSensorCount:
			IF ( NOT pusher_disable_request)AND LASER_SENSOR_2_IR_MEM THEN
				LASER_SENSOR_2_IR_MEM	:= FALSE;
				ACTUAL_BOXES := ACTUAL_BOXES  + 1;
				NUM_BOX_COUNTED := NUM_BOX_COUNTED + 1;
				COUNT_BOXES_NUMBER	:= COUNT_BOXES_NUMBER+1;
				CountPusherState	:= CountPusherState + 1;
				IF NOT FIRST_LAYER_OPERATION THEN
					

					IF NUM_BOX_COUNTED=8  THEN
						WaitCarriage				:= TRUE;
						IF NOT oddsequence  THEN
	  						FIRST_LAYER_OPERATION	:= NOT FIRST_LAYER_OPERATION;
						END_IF;
						
						NUM_BOX_COUNTED :=0;
						TimeCount:=150;
						TimeOut								:= FALSE;
						State_Feeder	:=WaitCheckTurnPusher; 
					ELSE	
						conveyor_if_enable_request		:=TRUE;
						State_Feeder	:=  WaitConveyorEnabled;	
			  
					END_IF;
					
				ELSE
					IF NUM_BOX_COUNTED=3 OR NUM_BOX_COUNTED=6   THEN
						
						IF (oddsequence AND NUM_BOX_COUNTED=6) OR (oddsequence AND NUM_BOX_COUNTED>3) THEN
							
							FIRST_LAYER_OPERATION	:= NOT FIRST_LAYER_OPERATION;
							NUM_BOX_COUNTED :=0;
						END_IF;
						TimeCount		:=150;
						TimeOut			:= FALSE;
						WaitCarriage				:= TRUE;
						State_Feeder	:= WaitCheckTurnPusher; 
					ELSE	
						conveyor_if_enable_request		:=TRUE;
						State_Feeder	:= WaitConveyorEnabled;	
			  
					END_IF;
				END_IF;		
			END_IF;
			
		WaitCheckTurnPusher:
			
			IF CountPusherState = 16  THEN
				turnpusher_enable_request	:= TRUE;
				CountPusherState 			:= 0;
				
			END_IF;
			IF CountPusherState = 12  THEN
				CountPusherState 			:= 0;
				turnpusher_disable_request	:= TRUE;
			END_IF;
			IF ACTUAL_BOXES<14 THEN
				index:=0;
			ELSE
				index:=1;
				FEERDER_WAIT_TO_DELIVER_BOXES :=TRUE;
			END_IF;
			
			State_Feeder	:= WaitConveyor_endStop; 
			
		WaitConveyor_endStop:
			
			TimeCount := TimeCount-1;
			
			IF TimeOut AND NOT FEEDER_ON_PHASE_STOP_WAIT AND NOT FEERDER_WAIT_TO_DELIVER_BOXES THEN
				
				carriage_2.Input_Target_Position 	:=Carriage_2_target_position_array[index]; 
				carriage_2.Actual_Command 			:= TARGETPOSITION;
				TimeOut								:= FALSE;
				State_Feeder	:= WaitCarriage_position;
			END_IF;
			
		WaitCarriage_position:
			IF carriage_2.InPosition THEN
				carriage_2.Actual_Command := HOMING;
				State_Feeder	:= WaitCarriage_Homing;
			END_IF;
			
		WaitCarriage_Homing:
			IF ((carriage_2.InPosition)AND (ACTUAL_BOXES<14)) THEN
				WaitCarriage				:= FALSE;
				State_Feeder	:= WaitConveyorEnabled;
			END_IF;
			IF (carriage_2.InPosition AND (ACTUAL_BOXES=14)) THEN
				oddsequence:= NOT oddsequence;
				FEERDER_BOXES_DELIVERED :=TRUE;
				ACTUAL_BOXES:=0;
			END_IF;
			IF (NOT carriage_2.InVelocity AND START_AGAIN_FEEDER) THEN
				START_AGAIN_FEEDER		:= FALSE;
				NUM_BOX_COUNTED			:=	0;
				WaitCarriage			:= FALSE;
				State_Feeder			:= WaitConveyorEnabled;
			END_IF;
			
		WaitStopSequence:
			IF  NOT pusher_disable_request AND NOT conveyor_turn1_disable_request AND NOT conveyor_end_disable_request  AND NOT carriage_2.InVelocity  THEN
				pusher_disable_request			:= TRUE;
				turnpusher_disable_request		:= TRUE;
				FEEDER_EMERGENCY_STOP	:= FALSE;
				FEEDER_IMMEDIATE_STOP	:= FALSE;
				FEEDER_ON_PHASE_STOP	:= FALSE;
				START_FEEDER			:= FALSE;

				IF emergency_stop  THEN
					emergency_stop := FALSE;
					FIRST_LAYER_OPERATION			:= FALSE;
					COUNT_BOXES_NUMBER				:=0;
					NUM_BOX_COUNTED					:= 0;
					ACTUAL_BOXES					:= 0;
	  				State_Feeder			:= WaitPowerON;
				ELSE
					State_Feeder			:= WaitStart;
				END_IF;
				
			END_IF;

			IF Stop_all THEN
				
				conveyor_if_disable_request		:= TRUE;
				conveyor_turn1_disable_request	:= TRUE;
				conveyor_end_disable_request	:= TRUE;
				carriage_2.Actual_Command 		:= POWEROFF;
				pusher_disable_request			:= TRUE;
				turnpusher_disable_request		:= TRUE;
				FIRST_LAYER_OPERATION			:= FALSE;
				COUNT_BOXES_NUMBER				:=0;
				NUM_BOX_COUNTED					:= 0;
				ACTUAL_BOXES					:= 0;
				Stop_all						:= TRUE;
				State_Feeder					:= WaitPowerON;
			END_IF;
		

	END_CASE
	IF FEEDER_STOP THEN
		FEEDER_STOP	:= FALSE;
		Stop_all	:= TRUE;
		State_Feeder					:= WaitStopSequence;
	END_IF;
	IF FEEDER_EMERGENCY_STOP OR FEEDER_IMMEDIATE_STOP THEN
		emergency_stop := TRUE;
		conveyor_if_disable_request		:= TRUE;
		conveyor_turn1_disable_request	:= TRUE;
		conveyor_end_disable_request	:= TRUE;
		carriage_2.Actual_Command 		:= STOP;
		
		State_Feeder					:= WaitStopSequence;
	END_IF;
	IF FEEDER_ON_PHASE_STOP THEN
		FEEDER_ON_PHASE_STOP_WAIT 	:= TRUE;
		FEEDER_ON_PHASE_STOP		:= FALSE;
	END_IF;	

	IF  TimeCount = 0 THEN
		TimeOut := TRUE;
		
	END_IF;
	
	conveyor_if.DeviceOperation := OperationType;
	conveyor_if.DeviceClock := TRUE;
	conveyor_if.DeviceDiagnosticsEnabled := TRUE;
	conveyor_if.DeviceEnablePreset := FALSE;
	conveyor_if.DeviceEnableTime := 10;
	conveyor_if.DeviceDisableTime := 10;
	conveyor_if.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	conveyor_if(DeviceEnableRequest := conveyor_if_enable_request, DeviceDisableRequest := conveyor_if_disable_request );
	ENABLE_CONVEYOR_IF:= conveyor_if.EnableDevice;
	// fault generation is directly manage in signal mnagement since it will desactivated
	CONVEYOR_IF_FAULT:= conveyor_if.DeviceFault;


	pusher.DeviceOperation := OperationType;
	pusher.DeviceClock := TRUE;
	pusher.DeviceDiagnosticsEnabled := TRUE;
	pusher.DeviceEnablePreset := FALSE;
	pusher.DeviceEnabledSensor := PUSHER_ENABLED;
	pusher.DeviceDisabledSensor := PUSHER_DISABLED;
	pusher.DeviceEnableTime := 10;
	pusher.DeviceDisableTime := 10;
	pusher.DeviceType := DEVICE_WITH_DOUBLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pusher(DeviceEnableRequest := pusher_enable_request, DeviceDisableRequest := pusher_disable_request );
	ENABLE_PUSHER:= pusher.EnableDevice;
	pusher.SimulationDeviceFault := SIMULATE_FAULT_PUSHER;
	PUSHER_FAULT:= (pusher.DeviceFault AND POWER_MACHINE);



	turnpusher.DeviceOperation := OperationType;
	turnpusher.DeviceClock := TRUE;
	turnpusher.DeviceDiagnosticsEnabled := TRUE;
	turnpusher.DeviceEnablePreset := FALSE;
	turnpusher.DeviceEnabledSensor := TURNPUSHER_ENABLED;
	turnpusher.DeviceDisabledSensor := TURNPUSHER_DISABLED;
	turnpusher.DeviceEnableTime := 100;
	turnpusher.DeviceDisableTime := 100;
	turnpusher.DeviceType := DEVICE_WITH_DOUBLE_FEEDBACK OR DEVICE_WITH_DOUBLE_ACTUATION;
	turnpusher(DeviceEnableRequest := turnpusher_enable_request, DeviceDisableRequest := turnpusher_disable_request );
	ENABLE_TURNPUSHER:= turnpusher.EnableDevice;
	DISABLE_TURNPUSHER := turnpusher.DisableDevice;
	turnpusher.SimulationDeviceFault := SIMULATE_FAULT_TURNPUSHER;
	TURNPUSHER_FAULT := (turnpusher.DeviceFault AND POWER_MACHINE);
	



	conveyor_turn1.DeviceOperation := OperationType;
	conveyor_turn1.DeviceClock := TRUE;
	conveyor_turn1.DeviceDiagnosticsEnabled := TRUE;
	conveyor_turn1.DeviceEnablePreset := FALSE;
	conveyor_turn1.DeviceEnableTime := 100;
	conveyor_turn1.DeviceDisableTime := 50;
	conveyor_turn1.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	conveyor_turn1(DeviceEnableRequest := conveyor_turn1_enable_request, DeviceDisableRequest := conveyor_turn1_disable_request );
	ENABLE_CONVEYOR_TURN1 := conveyor_turn1.EnableDevice;
	
	// fault generation is directly manage in signal mnagement since it will desactivated
	CONVEYOR_TURN1_FAULT := conveyor_turn1.DeviceFault;
	


	conveyor_end.DeviceOperation := OperationType;
	conveyor_end.DeviceClock := TRUE;
	conveyor_end.DeviceDiagnosticsEnabled := TRUE;
	conveyor_end.DeviceEnablePreset := FALSE;
	conveyor_end.DeviceEnableTime := 100;
	conveyor_end.DeviceDisableTime := 50;
	conveyor_end.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	conveyor_end(DeviceEnableRequest := conveyor_end_enable_request, DeviceDisableRequest := conveyor_end_disable_request );
	ENABLE_CONVEYOR_END := conveyor_end.EnableDevice;
	
	// fault generation is directly manage in signal mnagement since it will desactivated
	CONVEYOR_END_FAULT := conveyor_end.DeviceFault;
	
	
	carriage_2.DeviceClock := TRUE;
	carriage_2.DeviceTimer := 100;
	carriage_2.Reached_Postion:= CARRIAGE_RCHD_POS;
	carriage_2.DeviceFeedback := TRUE;
	carriage_2.InputSimulateError:=SIMULATE_FAULT_CARRIAGE_2; //input of fault then name
	CARRIAGE_2_FAULT:= carriage_2.OutputSimulateError;
	carriage_2.Actual_position:= ACTUAL_CARRIAGE_POS;
	CARRIAGE_TRG_POS := carriage_2.Output_Target_Position;
	carriage_2();
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM


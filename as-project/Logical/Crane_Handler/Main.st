
PROGRAM _INIT
	(* Insert code here *)
	gantrycranetarget_position_array[0]:= -1.11;
	gantrycranetarget_position_array[1]:= -1.3;
	index_gantry_crane:=0;
	
	
	box_crane_target_position_array[0]:= 0.01;
	box_crane_target_position_array[1]:= -0.195;
	box_crane_target_position_array[2]:= -0.2;
	index_box_crane:=0;
	
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	CASE State_Crane OF
		
		WaitPowerON:
			IF POWER_ON_CRANE THEN
				
				slide_rail_right_disable_request	:= TRUE;
				vacuum_box_crane_disable_request	:= TRUE;
				pusher_x_disable_request			:= TRUE;
				pusher_z_disable_request			:= TRUE;
				cartborad_disable_request			:= TRUE;
				box_crane.PowerON					:= TRUE;
				gantry_crane.PowerON				:= TRUE;
				State_Crane							:=WaitStart;
			END_IF;
		WaitStart:
			IF (START_CRANE AND NOT StartAgain) THEN
				START_CRANE		:= FALSE;
				State_Crane		:= WaitBox_craneMove;
			END_IF;
			IF (START_CRANE AND StartAgain) THEN
				StartAgain		:= FALSE;
	  			State_Crane		:= Crane_immediate_stop;
			END_IF;
			
		WaitBox_craneMove:
			IF NOT first_layer_release_CB AND NOT gantry_crane.InVelocity THEN
				Crane_immediate_stop := 2;
				index_box_crane					:= 1;
				IF box_crane.Powered THEN
					box_crane.Input_Target_Position := box_crane_target_position_array[index_box_crane];
					box_crane.Actual_Command		:= TARGETPOSITION;
					State_Crane						:= WaitTakeReleaseCartboard;
				END_IF;
			END_IF;		
			
			IF first_layer_release_CB AND NOT box_crane.InVelocity AND NOT gantry_crane.InVelocity THEN
				Crane_immediate_stop := 6;
				index_box_crane					:= 2;
				first_layer_release_CB			:= FALSE;
				box_crane.Input_Target_Position := box_crane_target_position_array[index_box_crane];
				box_crane.Actual_Command		:= TARGETPOSITION;
				release_cartboard				:= TRUE;
				State_Crane						:= WaitTakeReleaseCartboard;
			
			END_IF;
			

		WaitBox_craneMoveNEW:
			
			IF second_layer_release_CB  THEN
				Crane_immediate_stop := 6;
				IF  NOT pusher_z_enable_request AND NOT slide_rail_right_enable_request  THEN
					index_box_crane					:= 0;
					second_layer_release_CB			:= FALSE;
					box_crane.Input_Target_Position := box_crane_target_position_array[index_box_crane];
					box_crane.Actual_Command		:= TARGETPOSITION;
					box_crane_upper_position		:= TRUE;
					State_Crane						:= WaitBox_craneMoveNEW;	  
				END_IF;
			END_IF;
			IF box_crane_upper_position	AND  box_crane.InPosition THEN
				Crane_immediate_stop := 6;
				box_crane_upper_position		:= FALSE;
				release_cartboard				:= TRUE;
				Box_craneMoveNEW				:= TRUE;
				State_Crane						:= WaitGantry_craneMove;
			END_IF;
		WaitTakeReleaseCartboard:
			
			IF (NOT release_cartboard AND NOT CRANE_ON_PHASE_STOP_WAIT ) THEN
				Crane_immediate_stop := 4;
				IF box_crane.InPosition THEN
					cartborad_enable_request			:= TRUE;
					vacuum_box_crane_enable_request		:= TRUE;
					State_Crane						:= WaitBox_craneTakeHome;
				END_IF;
			END_IF;			
			
			
			IF (release_cartboard AND gantry_crane.InPosition ) OR (release_cartboard AND NOT box_crane.InVelocity AND NOT Box_craneMoveNEW ) THEN
				Crane_immediate_stop := 6;
				release_cartboard					:= FALSE;
				Box_craneMoveNEW					:= FALSE;
				vacuum_box_crane_disable_request	:= TRUE;
				cartborad_disable_request			:= TRUE;
				release_boxes						:= TRUE;
				State_Crane							:= WaitGantry_craneMove;
			END_IF;
			


		WaitBox_craneTakeHome:
			Crane_immediate_stop := 4;
			IF NOT cartborad_enable_request AND NOT vacuum_box_crane_enable_request THEN
				box_crane.Actual_Command		:= HOMING;
				CRANE_WAIT_BOXES				:= TRUE;
				COUNT_CARTBOARD_NUMBER				:= COUNT_CARTBOARD_NUMBER-1;
				SECOND_LAYER_OPERATION			:= NOT SECOND_LAYER_OPERATION;
				State_Crane						:= WaitBox_craneBoxes;
			END_IF;
		WaitBox_craneBoxes:
			Crane_immediate_stop := 5;
			IF NOT box_crane.InVelocity AND NOT CRANE_WAIT_BOXES  THEN
				pusher_z_enable_request			:= TRUE;
				slide_rail_right_enable_request	:= TRUE;
				IF NOT SECOND_LAYER_OPERATION THEN
					second_layer_release_CB			:= TRUE;
					State_Crane						:= WaitBox_craneMoveNEW;					
	 				
				ELSE
					State_Crane						:= WaitGantry_craneMove;
				END_IF;
	  			
			END_IF;
			
		WaitGantry_craneMove:
			
			IF NOT release_boxes AND NOT cartborad_enable_request AND NOT vacuum_box_crane_enable_request THEN
				Crane_immediate_stop := 6;
				IF NOT pusher_z_enable_request AND NOT slide_rail_right_enable_request THEN
					index_gantry_crane := 0;
					gantry_crane.Input_Target_Position := gantrycranetarget_position_array[index_gantry_crane];
					gantry_crane.Actual_Command		:= TARGETPOSITION;
					
					IF NOT SECOND_LAYER_OPERATION OR Box_craneMoveNEW THEN
						(*Box_craneMoveNEW				:= FALSE;*)
						release_cartboard				:= TRUE;
						//nwe step
						State_Crane						:= WaitTakeReleaseCartboard;
					ELSE
						first_layer_release_CB			:= TRUE;
						State_Crane						:= WaitBox_craneMove;
					END_IF;
					
				END_IF;
			END_IF;			
			
			IF release_boxes AND NOT cartborad_enable_request AND NOT vacuum_box_crane_enable_request THEN
				Crane_immediate_stop := 3;
				release_boxes						:= FALSE;
				index_gantry_crane 					:= 1;
				gantry_crane.Input_Target_Position  := gantrycranetarget_position_array[index_gantry_crane];
				gantry_crane.Actual_Command			:= TARGETPOSITION;
				State_Crane							:= WaitSlide_rail_rightMove;
			END_IF;


		WaitSlide_rail_rightMove:
			Crane_immediate_stop := 5;
			IF gantry_crane.InPosition THEN
				slide_rail_right_disable_request	:= TRUE;
				State_Crane							:= WaitGantry_cranePusher_xMove;
			END_IF;
	
		WaitGantry_cranePusher_xMove:
			Crane_immediate_stop := 9;
			IF  NOT slide_rail_right_disable_request THEN
	  			pusher_x_enable_request			:= TRUE;
				gantry_crane.Actual_Command		:= HOMING;
				
			State_Crane							:= WaitPusher_xPusher_zMove;	
			END_IF;
		WaitPusher_xPusher_zMove:
			Crane_immediate_stop := 8;
			IF NOT gantry_crane.InVelocity AND NOT pusher_x_enable_request THEN
				pusher_x_disable_request		:= TRUE;
				pusher_z_disable_request		:= TRUE;
				CRANE_BOXES_DELIVERED			:= TRUE;
				State_Crane							:= WaitBox_craneMove;	
			END_IF;
			
		WaitStopSequence:
			IF 	(NOT box_crane.InVelocity AND NOT gantry_crane.InVelocity)  THEN

				State_Crane					:= WaitStart;	
			END_IF;
		  
		WaitEmergenceStopSequence:
	END_CASE;
	
	IF CRANE_STOP THEN
		CRANE_STOP	:= FALSE;
		gantry_crane.Actual_Command 		:= POWEROFF;
		box_crane.Actual_Command 			:= POWEROFF;
		pusher_x_disable_request			:= TRUE;
		pusher_z_disable_request			:= TRUE;
		slide_rail_right_disable_request	:= TRUE;
		State_Crane							:= WaitPowerON;
	END_IF;

	IF CRANE_EMERGENCY_STOP THEN
		gantry_crane.Actual_Command 		:= STOP;
		box_crane.Actual_Command 			:= STOP;
		CRANE_EMERGENCY_STOP				:= FALSE;
		State_Crane							:= WaitStopSequence;
	END_IF;
	
	IF  CRANE_IMMEDIATE_STOP THEN
		StartAgain					:= TRUE;
		gantry_crane.Actual_Command 		:= STOP;
		box_crane.Actual_Command 			:= STOP;	
		IF release_boxes THEN
	  
		ELSIF ((SECOND_LAYER_OPERATION OR Box_craneMoveNEW) AND NOT release_boxes)   THEN
			
			IF NOT release_boxes  THEN
				SECOND_LAYER_OPERATION :=TRUE;
				Box_craneMoveNEW		:=TRUE;
			END_IF;
			State_Crane					:= WaitGantry_craneMove;
		ELSE
			State_Crane					:= WaitStart;
		END_IF;
		
	END_IF;
	IF CRANE_ON_PHASE_STOP THEN
		CRANE_ON_PHASE_STOP			:= FALSE;
		CRANE_ON_PHASE_STOP_WAIT 	:= TRUE;
		
	END_IF;	
	

	
	
	
	slide_rail_right.DeviceOperation := OperationType;	
	slide_rail_right.DeviceClock := TRUE;
	slide_rail_right.DeviceDiagnosticsEnabled := TRUE;
	slide_rail_right.DeviceEnablePreset := FALSE;
	slide_rail_right.DeviceEnableTime := 100;
	slide_rail_right.DeviceDisableTime := 100;
	slide_rail_right.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	slide_rail_right(DeviceEnableRequest := slide_rail_right_enable_request, DeviceDisableRequest := slide_rail_right_disable_request );
	ENABLE_SLIDE_RAIL_RIGHT := slide_rail_right.EnableDevice;
	slide_rail_right.SimulationDeviceFault	:= SIMULATE_FAULT_SLIDE_RAIL_RIGHT;
	SLIDE_RAIL_RIGHT_FAULT := (slide_rail_right.DeviceFault AND POWER_MACHINE);
	


	vacuum_box_crane.DeviceOperation := OperationType;
	vacuum_box_crane.DeviceClock := TRUE;
	vacuum_box_crane.DeviceDiagnosticsEnabled := FALSE;
	vacuum_box_crane.DeviceEnablePreset := FALSE;
	vacuum_box_crane.DeviceEnabledSensor := VACUUM_BOX_CRANE_ENABLED;
	vacuum_box_crane.DeviceEnableTime := 20;
	vacuum_box_crane.DeviceDisableTime := 20;
	vacuum_box_crane.DeviceType := DEVICE_WITH_ENABLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	vacuum_box_crane(DeviceEnableRequest := vacuum_box_crane_enable_request, DeviceDisableRequest := vacuum_box_crane_disable_request );
	ENABLE_VACUUM_BOX_CRANE := vacuum_box_crane.EnableDevice;
	vacuum_box_crane.SimulationDeviceFault	:= SIMULATE_FAULT_VACUUM_BOX_CRANE;
	VACUUM_BOX_CRANE_FAULT := (vacuum_box_crane.DeviceFault AND POWER_MACHINE);
	
	
	pusher_x.DeviceOperation := OperationType;
	pusher_x.DeviceClock := TRUE;
	pusher_x.DeviceDiagnosticsEnabled := FALSE;
	pusher_x.DeviceEnablePreset := FALSE;
	pusher_x.DeviceEnableTime := 100;
	pusher_x.DeviceDisableTime := 100;
	pusher_x.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pusher_x(DeviceEnableRequest := pusher_x_enable_request, DeviceDisableRequest := pusher_x_disable_request );
	ENABLE_PUSHER_X := pusher_x.EnableDevice;
	pusher_x.SimulationDeviceFault	:= SIMULATE_FAULT_PUSHER_X;
	PUSHER_X_FAULT := ( pusher_x.DeviceFault AND POWER_MACHINE);
	

	pusher_z.DeviceOperation := OperationType;
	pusher_z.DeviceClock := TRUE;
	pusher_z.DeviceDiagnosticsEnabled := FALSE;
	pusher_z.DeviceEnablePreset := FALSE;
	pusher_z.DeviceEnableTime := 100;
	pusher_z.DeviceDisableTime := 100;
	pusher_z.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pusher_z(DeviceEnableRequest := pusher_z_enable_request, DeviceDisableRequest := pusher_z_disable_request );
	ENABLE_PUSHER_Z := pusher_z.EnableDevice;
	pusher_z.SimulationDeviceFault	:= SIMULATE_FAULT_PUSHER_Z;
	PUSHER_Z_FAULT := (pusher_z.DeviceFault AND POWER_MACHINE);


	cartborad.DeviceOperation := OperationType;
	cartborad.DeviceClock := TRUE;
	cartborad.DeviceDiagnosticsEnabled := FALSE;
	cartborad.DeviceEnablePreset := FALSE;
	cartborad.DeviceEnableTime := 25;
	cartborad.DeviceDisableTime := 25;
	cartborad.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	cartborad(DeviceEnableRequest := cartborad_enable_request, DeviceDisableRequest := cartborad_disable_request );
	ENABLE_CARTBORAD := cartborad.EnableDevice;
	cartborad.SimulationDeviceFault	:= SIMULATE_FAULT_CARTBORAD;
	CARTBORAD_FAULT := (cartborad.DeviceFault AND POWER_MACHINE);
	IF cartborad.DeviceFault THEN
		coutn := coutn + 1;
		
		
	END_IF;
	
	
	gantry_crane.DeviceClock := TRUE;
	gantry_crane.DeviceTimer := 100 ;
	gantry_crane.Reached_Postion:= GANTRY_CRANE_RCHD_POS;// no available without feedback
	gantry_crane.DeviceFeedback := FALSE;
	gantry_crane.InputSimulateError:=SIMULATE_FAULT_GANTRY_CRANE;
	GANTRY_CRANE_FAULT := gantry_crane.OutputSimulateError;
	gantry_crane.Actual_position:= ACTUAL_GANTRY_CRANE_POS;
	GANTRY_CRANE_TRG_POS := gantry_crane.Output_Target_Position;
	
	gantry_crane();
	
	
	box_crane.DeviceClock := TRUE;
	box_crane.DeviceTimer := 100 ;
	box_crane.Reached_Postion:= BOX_CRANE_RCHD_POS;// no available without feedback
	box_crane.DeviceFeedback := FALSE;
	box_crane.InputSimulateError:=SIMULATE_FAULT_BOX_CRANE;
	BOX_CRANE_FAULT := box_crane.OutputSimulateError ;
	box_crane.Actual_position:= ACTUAL_BOX_CRANE_POS;
	BOX_CRANE_TRG_POS := box_crane.Output_Target_Position;
	box_crane();
	
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM


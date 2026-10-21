
PROGRAM _INIT
	(* Insert code here *)
	palletliftertargetposition_array[0]:= -0.12;
	palletliftertargetposition_array[1]:= -0.258;
	index_palletlifter:=0;
	
	
	
	pallet_convtarget_velocity_array[0]:= 0.1;
	pallet_convtarget_velocity_array[1]:= 0.5;
	index_pallet_conv:=0;
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
	 
	CASE State_Pallet OF
		WaitPPowerON:
			IF POWER_ON_PALLET THEN
				
				pallet_conv_1_disable_request	:= TRUE;
				pallet_fork_disable_request 	:= TRUE;
				pallet_lifter.PowerON			:= TRUE;
				pallet_conveyor_2.PowerON		:= TRUE;
				State_Pallet							:=WaitPStart;
			END_IF;

		WaitPStart:
			IF (START_PALLET) THEN
				START_PALLET		:= FALSE;
				POWER_ON_PALLET		:= FALSE;
				State_Pallet		:= Waitpallet_lifterMove;
			END_IF;
			IF (START_PALLET AND AFTER_IMMEDIATE_STOP) THEN
				State_Pallet		:= pallet_immadiate_stop;
			END_IF;
			
		Waitpallet_lifterMove:
			pallet_immadiate_stop :=2;
			IF (pallet_lifter.Powered AND NOT odditeration )  THEN
				
				index_palletlifter	:=	1;
				pallet_lifter.Input_Target_Position	:= palletliftertargetposition_array[index_palletlifter];
				pallet_lifter.Actual_Command := TARGETPOSITION;
				State_Pallet		:= Waitpallet_forkMove;
			END_IF;

			IF (NOT pallet_fork_enable_request AND odditeration) OR (AFTER_IMMEDIATE_STOP AND odditeration) THEN
				index_palletlifter	:=	0;
				pallet_lifter.Input_Target_Position	:= palletliftertargetposition_array[index_palletlifter];
				pallet_lifter.Actual_Command := TARGETPOSITION;
				State_Pallet		:= Waitpallet_forkMove;
			END_IF;
		Waitpallet_forkMove:
			pallet_immadiate_stop 	:= 3;
			
			IF (pallet_lifter.InPosition AND NOT odditeration) OR (AFTER_IMMEDIATE_STOP AND  NOT odditeration)THEN
				pallet_fork_enable_request	:= TRUE;
				pallet_immadiate_stop 	:= 2;
				odditeration			:= NOT odditeration;
				State_Pallet			:= Waitpallet_lifterMove;
			END_IF;
			IF  (pallet_lifter.InPosition AND odditeration AND index_palletlifter = 0 ) OR (AFTER_IMMEDIATE_STOP AND odditeration)THEN

				pallet_fork_disable_request	:= TRUE;
				odditeration			:= NOT odditeration;
				pallet_immadiate_stop 	:= 4;
				State_Pallet			:= WaitpalletHome;
			END_IF;

			
		WaitpalletHome:
			pallet_immadiate_stop 	:= 4;			
			IF NOT pallet_fork_disable_request	 OR (AFTER_IMMEDIATE_STOP) THEN
				pallet_lifter.Actual_Command := HOMING;
				TimerCount		:=50;
				Timedelay		:= FALSE;
				State_Pallet			:= Waitpallet_conveyor_1Move;
			END_IF;
			
		Waitpallet_conveyor_1Move:
			pallet_immadiate_stop 	:= 5;
			TimerCount := TimerCount-1;
			IF Timedelay OR (AFTER_IMMEDIATE_STOP) THEN
				index_pallet_conv						:= 1;
				pallet_conveyor_2.Input_Target_Velocity	:= pallet_convtarget_velocity_array[index_pallet_conv];
				pallet_conveyor_2.Actual_Command		:= TARGETVELOCITY;
				IF Takeoff_pallet  THEN
					Takeoff_pallet			:= FALSE;
	  				State_Pallet			:= Waitpallet_lifterMove;
				ELSE
					pallet_conv_1_enable_request	:= TRUE;
					State_Pallet			:= Waitlight_barrier_2;
				END_IF;
				
			END_IF;
			
			
		Waitlight_barrier_2:	
			pallet_immadiate_stop 	:= 8;
			
			IF PALLET_LIGHT_BARRIER_2 AND pallet_conveyor_2.InVelocity AND NOT pallet_conv_1_enable_request THEN
				pallet_conv_1_disable_request := TRUE;
				index_pallet_conv		:= 0;
				pallet_immadiate_stop 	:= 7;
				pallet_conveyor_2.Input_Target_Velocity		:= pallet_convtarget_velocity_array[index_pallet_conv];
				pallet_conveyor_2.Actual_Command		:= TARGETVELOCITY;
				State_Pallet					:= Waitlight_barrier_1;
			END_IF;
		

		Waitlight_barrier_1:
			pallet_immadiate_stop 	:= 7;
			IF (PALLET_LIGHT_BARRIER_1 AND pallet_conveyor_2.InVelocity ) OR (AFTER_IMMEDIATE_STOP)  THEN
				COUNT_PALLET_NUMBER					:= COUNT_PALLET_NUMBER	-1;
				PALLET_WAIT_BOXES					:= TRUE;
				pallet_conveyor_2.Actual_Command	:= HOMING;
				State_Pallet						:= Waitcraneandstart;
			END_IF;	
			
		Waitcraneandstart:
			pallet_immadiate_stop 		:= 9;
			IF (NOT pallet_conveyor_2.InVelocity AND NOT PALLET_WAIT_BOXES AND NOT PALLET_ON_PHASE_STOP_WAIT AND NOT pallet_conv_1_disable_request)  OR (AFTER_IMMEDIATE_STOP) OR (PHASE_STOP_WAIT)THEN
				Takeoff_pallet			:= TRUE;
				Timedelay				:= TRUE;
				PHASE_STOP_WAIT			:= FALSE;
				State_Pallet			:=  Waitpallet_conveyor_1Move;
			END_IF;
			
		WaitOnPhaseStopSequence:

			IF PALLET_ON_PHASE_STOP_REMOVE THEN	//special activation of motore 2 to remove the current pallet	 
				index_pallet_conv		:= 1;
				pallet_conveyor_2.Input_Target_Velocity		:= pallet_convtarget_velocity_array[index_pallet_conv];
				pallet_conveyor_2.Actual_Command		:= TARGETVELOCITY;
				IF NOT PALLET_ON_PHASE_STOP_WAIT THEN
					PHASE_STOP_WAIT					:= TRUE;
//					PALLET_WAIT_BOXES					:= FALSE;
					PALLET_ON_PHASE_STOP_REMOVE		:= FALSE;

					State_Pallet					:= Waitcraneandstart;
				END_IF;
			END_IF;
			IF PALLET_ON_PHASE_STOP_IDLE THEN
				PALLET_ON_PHASE_STOP_IDLE 		:= FALSE;
	  			State_Pallet					:= Waitcraneandstart;
			END_IF;
		

	END_CASE;
	IF  TimerCount = 0 THEN
		Timedelay := TRUE;
	END_IF;
	IF PALLET_STOP THEN
		PALLET_STOP	:= TRUE;
		pallet_lifter.Actual_Command			:= POWEROFF;
		pallet_conveyor_2.Actual_Command 		:= POWEROFF;
		pallet_conv_1_disable_request			:= TRUE;
		pallet_fork_disable_request				:= TRUE;
		State_Pallet							:= WaitPPowerON;
	END_IF;
	IF PALLET_EMERGENCY_STOP THEN
		pallet_lifter.Actual_Command			:= STOP;
		pallet_conveyor_2.Actual_Command 		:= STOP;
		pallet_conv_1_disable_request			:= TRUE;
		PALLET_EMERGENCY_STOP					:= FALSE;
		State_Pallet								:=WaitPPowerON;
	END_IF;
	
	IF  PALLET_IMMEDIATE_STOP THEN
		
		pallet_lifter.Actual_Command			:= STOP;
		pallet_conveyor_2.Actual_Command 		:= STOP;
		pallet_conv_1_disable_request	:= TRUE;
		AFTER_IMMEDIATE_STOP					:= TRUE;
		State_Pallet							:=WaitPPowerON;
		
	END_IF;
	IF PALLET_ON_PHASE_STOP THEN
				
		PALLET_ON_PHASE_STOP_WAIT 	:= TRUE;
		IF PALLET_WAIT_BOXES THEN
			PALLET_ON_PHASE_STOP				:= FALSE;
	  		State_Pallet					:= WaitOnPhaseStopSequence;
		END_IF;

	END_IF;	
	

	
	
	pallet_conveyor_1.DeviceOperation := OperationType;
	pallet_conveyor_1.DeviceClock := TRUE;
	pallet_conveyor_1.DeviceDiagnosticsEnabled := TRUE;
	pallet_conveyor_1.DeviceEnablePreset := FALSE;
	pallet_conveyor_1.DeviceEnableTime := 25;
	pallet_conveyor_1.DeviceDisableTime := 25;
	pallet_conveyor_1.DeviceType := DEVICE_WITHOUT_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pallet_conveyor_1(DeviceEnableRequest := pallet_conv_1_enable_request, DeviceDisableRequest := pallet_conv_1_disable_request );
	ENABLE_PALLET_CONVEYOR_1 := pallet_conveyor_1.EnableDevice;
	// fault generation is directly manage in signal mnagement since it will desactivated
	
	PALLET_CONVEYOR_1_FAULT := pallet_conveyor_1.SimulationDeviceFault;
	IF PALLET_CONVEYOR_1_FAULT THEN
		coutn := coutn + 1;
		
	END_IF;

	pallet_fork.DeviceOperation := OperationType;
	pallet_fork.DeviceClock := TRUE;
	pallet_fork.DeviceDiagnosticsEnabled := TRUE;
	pallet_fork.DeviceEnablePreset := FALSE;
	pallet_fork.DeviceEnabledSensor := PALLET_FORK_ENABLED;
	pallet_fork.DeviceEnableTime := 100;
	pallet_fork.DeviceDisableTime := 100;
	pallet_fork.DeviceType := DEVICE_WITH_ENABLE_FEEDBACK OR DEVICE_WITH_SINGLE_ACTUATION;
	pallet_fork(DeviceEnableRequest := pallet_fork_enable_request, DeviceDisableRequest := pallet_fork_disable_request );
	ENABLE_PALLET_FORK := pallet_fork.EnableDevice;
	pallet_fork.SimulationDeviceFault	:= SIMULATE_FAULT_PALLET_FORK;
	PALLET_FORK_FAULT := pallet_fork.SimulationDeviceFault (*pallet_fork.DeviceFault*);

	
	
	pallet_conveyor_2.DeviceClock := TRUE;
	pallet_conveyor_2.DeviceTimer := 10 ;
	pallet_conveyor_2.DeviceFeedback := FALSE;
	pallet_conveyor_2.InputSimulateError:=SIMULATE_FAULT_PALLET_CONVEYOR_2;
	PALLET_CONVEYOR_2_FAULT := pallet_conveyor_2.OutputSimulateError;
	PALLET_CONVEYOR_2_TRG_VEL := pallet_conveyor_2.Output_Target_Velocity;
	pallet_conveyor_2();

	
	
	pallet_lifter.DeviceClock := TRUE;
	pallet_lifter.DeviceTimer := 10 ;
	pallet_lifter.Reached_Postion:= PALLET_LIFTER_RCHD_POS; // no available without feedback
	pallet_lifter.DeviceFeedback := FALSE;
	pallet_lifter.InputSimulateError:=SIMULATE_FAULT_PALLET_LIFTER;
	PALLET_LIFTER_FAULT := pallet_lifter.OutputSimulateError;
	pallet_lifter.Actual_position:= ACTUAL_PALLET_LIFTER_POS;
	PALLET_LIFTER_TRG_POS := pallet_lifter.Output_Target_Position;
	pallet_lifter();
	
	
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM


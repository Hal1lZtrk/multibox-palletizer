
PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
//CARRIAGE STATION 
	LASER_SENSOR_2_IR	:= ComTCP_SimInputs.laser_sensor2_IR;
	LASER_SENSOR_IR		:= ComTCP_SimInputs.laser_sensor_IR;
	PUSHER_DISABLED		:= ComTCP_SimInputs.pusher_LBK ;
	PUSHER_ENABLED		:= ComTCP_SimInputs.pusher_LFR	;
	TURNPUSHER_DISABLED:= ComTCP_SimInputs.turnpusher_LBK;
	TURNPUSHER_ENABLED:= ComTCP_SimInputs.turnpusher_LFR;
	ACTUAL_CARRIAGE_POS := ComTCP_SimInputs.carriage_2_AXIS;
	CARRIAGE_RCHD_POS 	:= ComTCP_SimInputs.carriage_2_RCHD;
//	ComTCP_SimInputs.NumSignals
	
//CRANE STATION
	ACTUAL_BOX_CRANE_POS    := ComTCP_SimInputs.box_crane_AXIS;
	ACTUAL_GANTRY_CRANE_POS := ComTCP_SimInputs.gantry_crane_AXIS;
	VACUUM_BOX_CRANE_ENABLED:= ComTCP_SimInputs.vaccum_box_crane_VACUUM;
	
	(*INPUT FILTER*)
	IF LASER_SENSOR_IR THEN
		LASER_SENSOR_IR_MEM	:=TRUE;
		
	END_IF;
	IF LASER_SENSOR_2_IR THEN
		LASER_SENSOR_2_IR_MEM	:=TRUE;
	
	END_IF;
// PALLET STATION	
	ACTUAL_PALLET_LIFTER_POS := ComTCP_SimInputs.pallet_lifter_AXIS;
	PALLET_FORK_ENABLED			:= ComTCP_SimInputs.pallet_fork_left_FB;
	PALLET_LIGHT_BARRIER_1		:= ComTCP_SimInputs.pallet_light_barrier_1_IR;
	PALLET_LIGHT_BARRIER_2		:= ComTCP_SimInputs.pallet_light_barrier_2_IR;
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM



PROGRAM _INIT
	(* Insert code here *)
	 
END_PROGRAM

PROGRAM _CYCLIC
	(* Insert code here *)
//CARRIAGE STATION	
	ComTCP_SimOutputs.carriage_2_TGT_POS:=CARRIAGE_TRG_POS;
	
	ComTCP_SimOutputs.conveyor_if_FWD :=ENABLE_CONVEYOR_IF;
	ComTCP_SimOutputs.pusher_FW	:= ENABLE_PUSHER;
	ComTCP_SimOutputs.conveyer_turn1_FWD :=ENABLE_CONVEYOR_TURN1;	
	ComTCP_SimOutputs.conveyer_end_FWD :=ENABLE_CONVEYOR_END;
	ComTCP_SimOutputs.turnpusher_FWD	:= DISABLE_TURNPUSHER;
	ComTCP_SimOutputs.turnpusher_BWD	:= ENABLE_TURNPUSHER;
//CRANE STATION
	ComTCP_SimOutputs.box_crane_TGT_POS		:= BOX_CRANE_TRG_POS;
	ComTCP_SimOutputs.cartboard_TRIG		:= ENABLE_CARTBORAD;
	ComTCP_SimOutputs.gantry_crane_TGT_POS	:= GANTRY_CRANE_TRG_POS;
	ComTCP_SimOutputs.pusher_x_EN			:= ENABLE_PUSHER_X;
	ComTCP_SimOutputs.pusher_z_EN			:= ENABLE_PUSHER_Z;
	ComTCP_SimOutputs.slide_rail_right_EN	:= ENABLE_SLIDE_RAIL_RIGHT;
	ComTCP_SimOutputs.vaccum_box_crane_GRIP	:= ENABLE_VACUUM_BOX_CRANE;
//PALLET STATION	
	ComTCP_SimOutputs.pallet_lifter_TGT_POS	:= PALLET_LIFTER_TRG_POS;
	ComTCP_SimOutputs.pallet_fork_left_EN	:= ENABLE_PALLET_FORK;
	ComTCP_SimOutputs.pallet_conveyor_1_FWD	:= ENABLE_PALLET_CONVEYOR_1;
	ComTCP_SimOutputs.pallet_conveyor_2_ACT_VEL	:= PALLET_CONVEYOR_2_TRG_VEL;
	ComTCP_SimOutputs.pallet_lifter_TGT_POS	:= PALLET_LIFTER_TRG_POS;
//	ComTCP_SimOutputs.NumSignals
END_PROGRAM

PROGRAM _EXIT
	(* Insert code here *)
	 
END_PROGRAM


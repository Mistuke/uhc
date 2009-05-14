%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Memory management: plan: semi space (SS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A semi space plan uses two spaces of which one is used to allocate, the other to copy surviving
objects into.
See XXX.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  defs & types
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
// the administration
typedef struct MM_Plan_SS_Data {
	MM_Space			fragSpace0 ; 		// the 2 lower level spaces
	MM_Space			fragSpace1 ;
	MM_Space			space0 ; 			// the 2 semi spaces
	MM_Space			space1 ;
	MM_Space*			toSpace ;			// the active allocation space
	MM_Space*			fromSpace ;			// the collected space
	MM_Allocator		ssAllocator ;		// and its allocator
	MM_Allocator		residentAllocator ;	// for allocations remaining resident/nonrelocated
	MM_Collector		collector ;
	MM_Malloc			memMgt ;
	MM_TraceSupply*		queTraceSupply ;	// trace request queue
	MM_TraceSupply		allTraceSupply ;	// all trace supplies grouped together
	MM_Trace			gbmTrace ;			// GBM specific
	MM_Module			gbmModule ;			// GBM specific module info
	Bool				gcInProgress ;
} MM_Plan_SS_Data ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
extern void mm_plan_SS_Init( MM_Plan* ) ;
extern Bool mm_plan_SS_PollForGC( MM_Plan*, Bool isSpaceFull, MM_Space* space ) ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  interface object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
extern MM_Plan mm_plan_SS ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#ifdef TRACE
extern void mm_plan_SS_Test() ;
#endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Memory management: plan: semi space (SS)
%%% see associated .ch file for more info.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#include "../../rts.h"
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SS internal defs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SS internal functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SS interface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
void mm_plan_SS_Init( MM_Plan* plan ) {
	MM_Plan_SS_Data* plss = mm_malloc_LOF.malloc( sizeof(MM_Plan_SS_Data) ) ;
	// IF_GB_TR_ON(3,{printf("mm_plan_SS_Init plan=%x plss=%x\n",plan,plss);}) ;
	
	plss->memMgt = mm_malloc_LOF ;
	plss->residentAllocator = mm_allocator_LOF ;
	
	plss->fragSpace0 = mm_space_Fragment ;
	plss->fragSpace0.init( &plss->fragSpace0, &plss->memMgt, &mm_pages_Buddy ) ;
	plss->space0 = mm_space_CopySpace ;
	plss->space0.initWithSpace( &plss->space0, &plss->memMgt, &plss->fragSpace0 ) ;
	
	plss->fragSpace1 = mm_space_Fragment ;
	plss->fragSpace1.init( &plss->fragSpace1, &plss->memMgt, &mm_pages_Buddy ) ;
	plss->space1 = mm_space_CopySpace ;
	plss->space1.initWithSpace( &plss->space1, &plss->memMgt, &plss->fragSpace1 ) ;
	
	plss->toSpace = &plss->space0 ;
	plss->fromSpace = &plss->space1 ;

	plss->ssAllocator = mm_allocator_Bump ;
	plss->ssAllocator.init( &plss->ssAllocator, &plss->memMgt, plss->toSpace ) ;
		
	plss->collector = mm_collector_SS ;
	plss->collector.init( &plss->collector, &plss->memMgt, plan ) ;
	// plan->collector = &plss->collector ;
	
#ifdef __UHC_TARGET_BC__
	mm_mutator = mm_mutator_GBSS ;
	mm_mutator.init
		( &mm_mutator
		, &plss->memMgt
		, &plss->ssAllocator
		, &plss->residentAllocator
		, &plss->gbmTrace
		, &plss->gbmModule
%%[[90
		, &mm_weakPtr					// init later
		, &plss->weakPtrFinalizeQue		// init later
%%]]
		) ;
	plan->mutator = &mm_mutator ;
#endif

#ifdef __UHC_TARGET_C__
	mm_mutator = mm_ssmutator_C ;
	mm_mutator.init
		( &mm_mutator
		, &plss->memMgt
		, &plss->ssAllocator
		, &plss->residentAllocator
		, &plss->gbmTrace
		, &plss->gbmModule
%%[[90
		, &mm_weakPtr					// init later
		, &plss->weakPtrFinalizeQue		// init later
%%]]
		) ;
	plan->mutator = &mm_mutator ;
#endif

#ifdef __UHC_TARGET_LLVM__
	mm_mutator = mm_ssmutator_llvm ;
	mm_mutator.init
		( &mm_mutator
		, &plss->memMgt
		, &plss->ssAllocator
		, &plss->residentAllocator
		, &plss->gbmTrace
		, &plss->gbmModule
%%[[90
		, &mm_weakPtr					// init later
		, &plss->weakPtrFinalizeQue		// init later
%%]]
		) ;
	plan->mutator = &mm_mutator ;
#endif



#ifdef __UHC_TARGET_BC__
%%[[8
	MM_FlexArray* traceSupplies = mm_flexArray_New( &plss->memMgt, NULL, sizeof(MM_TraceSupply), 5, 5 ) ;
%%][99
	MM_FlexArray* traceSupplies = mm_flexArray_New( &plss->memMgt, NULL, sizeof(MM_TraceSupply), 6, 6 ) ;
%%]]
	// IF_GB_TR_ON(3,{printf("mm_plan_SS_Init B\n");}) ;
	// the order of these supplies matters, because they are run in this order, the last must be the one queueing
	MM_TraceSupply* regsTraceSupply   = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 0 ) ;
	MM_TraceSupply* rootsTraceSupply  = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 1 ) ;
	MM_TraceSupply* stackTraceSupply  = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 2 ) ;
	MM_TraceSupply* moduleTraceSupply = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 3 ) ;
%%[[8
	MM_TraceSupply* queTraceSupply    = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 4 ) ;
%%][99
	MM_TraceSupply* finQueTraceSupply = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 4 ) ;
	MM_TraceSupply* queTraceSupply    = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 5 ) ;
%%]]
#endif

#ifdef __UHC_TARGET_C__
%%[[8
	MM_FlexArray* traceSupplies = mm_flexArray_New( &plss->memMgt, NULL, sizeof(MM_TraceSupply), 2, 2 ) ;
%%][99
	MM_FlexArray* traceSupplies = mm_flexArray_New( &plss->memMgt, NULL, sizeof(MM_TraceSupply), 2, 2 ) ;
%%]]
	// IF_GB_TR_ON(3,{printf("mm_plan_SS_Init B\n");}) ;
	// the order of these supplies matters, because they are run in this order, the last must be the one queueing
	MM_TraceSupply* stackTraceSupply  = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 0 ) ;
%%[[8
	MM_TraceSupply* queTraceSupply    = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 1 ) ;
%%][99
//	MM_TraceSupply* finQueTraceSupply = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 1 ) ;
	MM_TraceSupply* queTraceSupply    = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 1 ) ;
%%]]
#endif

#ifdef __UHC_TARGET_LLVM__
%%[[8
	MM_FlexArray* traceSupplies = mm_flexArray_New( &plss->memMgt, NULL, sizeof(MM_TraceSupply), 3, 3 ) ;
%%][99
	MM_FlexArray* traceSupplies = mm_flexArray_New( &plss->memMgt, NULL, sizeof(MM_TraceSupply), 3, 3 ) ;
%%]]
	// IF_GB_TR_ON(3,{printf("mm_plan_SS_Init B\n");}) ;
	// the order of these supplies matters, because they are run in this order, the last must be the one queueing
	MM_TraceSupply* globalsTraceSupply  = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 0 ) ;
	MM_TraceSupply* stackTraceSupply    = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 1 ) ;
%%[[8
	MM_TraceSupply* queTraceSupply    = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 2 ) ;
%%][99
//	MM_TraceSupply* finQueTraceSupply = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 2 ) ;
	MM_TraceSupply* queTraceSupply    = (MM_TraceSupply*)mm_flexArray_At( traceSupplies, 2 ) ;
%%]]
#endif



	
#ifdef __UHC_TARGET_BC__
	*regsTraceSupply = mm_traceSupply_GBRegs ;
	regsTraceSupply->init( regsTraceSupply, &plss->memMgt, plan->mutator ) ;
	
	*rootsTraceSupply = mm_traceSupply_Roots ;
	rootsTraceSupply->init( rootsTraceSupply, &plss->memMgt, plan->mutator ) ;

	*stackTraceSupply = mm_traceSupply_GBStack ;
	stackTraceSupply->init( stackTraceSupply, &plss->memMgt, plan->mutator ) ;
	
	*moduleTraceSupply = mm_traceSupply_GBModule ;
	moduleTraceSupply->init( moduleTraceSupply, &plss->memMgt, plan->mutator ) ;

%%[[99
	*finQueTraceSupply = mm_traceSupply_WeakPtrFinalizeQue ;
	finQueTraceSupply->init( finQueTraceSupply, &plss->memMgt, plan->mutator ) ;
%%]]

#endif

#ifdef __UHC_TARGET_C__
	*stackTraceSupply = mm_traceSupplyStack_C ;
	stackTraceSupply->init( stackTraceSupply, &plss->memMgt, plan->mutator ) ;

%%[[99
//	*finQueTraceSupply = mm_traceSupply_WeakPtrFinalizeQue ;
//	finQueTraceSupply->init( finQueTraceSupply, &plss->memMgt, plan->mutator ) ;
%%]]

#endif

#ifdef __UHC_TARGET_LLVM__

	*globalsTraceSupply = mm_traceSupplyGlobals_llvm ;
	globalsTraceSupply->init( globalsTraceSupply, &plss->memMgt, plan->mutator ) ;

	*stackTraceSupply = mm_traceSupplyStack_llvm ;
	stackTraceSupply->init( stackTraceSupply, &plss->memMgt, plan->mutator ) ;

%%[[99
//	*finQueTraceSupply = mm_traceSupply_WeakPtrFinalizeQue ;
//	finQueTraceSupply->init( finQueTraceSupply, &plss->memMgt, plan->mutator ) ;
%%]]

#endif

	*queTraceSupply = mm_traceSupply_Buffer ; // mm_traceSupply_Bump ; // mm_traceSupply_Buffer ;
	queTraceSupply->init( queTraceSupply, &plss->memMgt, plan->mutator ) ;
	plss->queTraceSupply = queTraceSupply ;
	
	plss->allTraceSupply = mm_traceSupply_Group ;
	plss->allTraceSupply.initWithSub( &plss->allTraceSupply, &plss->memMgt, plan->mutator, traceSupplies ) ;

#ifdef __UHC_TARGET_BC__
	plss->gbmTrace = mm_trace_GBM ;
	plss->gbmTrace.init( &plss->gbmTrace, plss->queTraceSupply, &plss->ssAllocator, &plss->collector ) ;
	
	plss->gbmModule = mm_module_GBSS ;
	plss->gbmModule.init( &plss->gbmModule, &plss->memMgt ) ;
#endif

#ifdef __UHC_TARGET_C__
	plss->gbmTrace = mm_trace_C ;
	plss->gbmTrace.init( &plss->gbmTrace, plss->queTraceSupply, &plss->ssAllocator, &plss->collector ) ;
#endif

#ifdef __UHC_TARGET_LLVM__
	plss->gbmTrace = mm_trace_llvm ;
	plss->gbmTrace.init( &plss->gbmTrace, plss->queTraceSupply, &plss->ssAllocator, &plss->collector ) ;
#endif

%%[[90
	mm_weakPtr = mm_weakPtr_List ;
	plss->weakPtr = &mm_weakPtr ;
#ifdef __UHC_TARGET_BC__
	plss->weakPtr->init( plss->weakPtr, &mm_mutator, &plss->collector ) ;
	
	mm_deque_InitWithSize( &plss->weakPtrFinalizeQue, &plss->memMgt, MM_WeakPtrFinalizeQue_Data_SizeInWords ) ;
#endif
%%]]

	plss->gcProgress = 0 ;
	
	plan->data = (MM_Plan_Data_Priv*)plss ;
	// IF_GB_TR_ON(3,{printf("mm_plan_SS_Init C plan=%x plss=%x\n",plan,plss);}) ;
}

void mm_plan_SS_Exit( MM_Plan* plan ) {
	MM_Plan_SS_Data* plss = (MM_Plan_SS_Data*)plan->data ;
	// IF_GB_TR_ON(3,{printf("mm_plan_SS_Init plan=%x plss=%x\n",plan,plss);}) ;
#ifdef __UHC_TARGET_BC__
%%[[90
	plss->weakPtr->finalizeAllWeakPtr( plss->weakPtr ) ;
%%]]
#endif
}

#if MM_BYPASS_PLAN
void mm_plan_SS_InitBypass( MM_Plan* plan ) {
	MM_Plan_SS_Data* plss = (MM_Plan_SS_Data*)plan->data ;
	
	mm_bypass_allocator = &plss->ssAllocator ;	
}
#endif
%%]

%%[90
MM_DEQue* mm_plan_SS_GetWeakPtrFinalizeQue( MM_Plan* plan ) {
	MM_Plan_SS_Data* plss = (MM_Plan_SS_Data*)plan->data ;
	
	return &plss->weakPtrFinalizeQue ;	
}
%%]

%%[8
Bool mm_plan_SS_DoGC( MM_Plan* plan, Bool isPreemptiveGC /*isSpaceFull*/, Word gcInfo ) {
	MM_Plan_SS_Data* plss = (MM_Plan_SS_Data*)plan->data ;
	Bool res ;

	plss->collector.collectPre( &plss->collector ) ;

	if ( plss->gcProgress & MM_PLAN_SS_GCPROGRESS_COLLECTING ) {
		rts_panic1_0( "mm_plan_SS_DoGC already in progress" ) ;
	}
	plss->gcProgress |= MM_PLAN_SS_GCPROGRESS_COLLECTING ;
	
	IF_GB_TR_ON(3,{printf("mm_plan_SS_DoGC-BEF plan=%p plss=%p\n",plan,plss);}) ;
	// if ( isSpaceFull ) {
		// total as used previously
		Word prevTotalSz = plss->ssAllocator.getTotalSize( &plss->ssAllocator ) ;
		// collect, which also switches spaces

        Word beforeUsedSz = plss->ssAllocator.getUsedSize( &plss->ssAllocator ) ;
		plss->collector.collect( &plss->collector, gcInfo ) ;
        Word afterUsedSz = plss->ssAllocator.getUsedSize( &plss->ssAllocator ) ;

        //if(beforeUsedSz != afterUsedSz) {
            //fprintf(stderr, "#### TOTAL MEM: %i | USED MEM BEFORE GC: %i AFTER GC: %i \n", prevTotalSz, beforeUsedSz, afterUsedSz);
        // }

		// total as used now
		if ( ! isPreemptiveGC ) {
			Word curUsedSz = plss->ssAllocator.getUsedSize( &plss->ssAllocator ) ;
			Word onePercentSz = prevTotalSz / 100 ;
			Word percentageFree = (prevTotalSz - curUsedSz) / onePercentSz ;
			// adapt max size of space, based on current occupancy rate, this is currently a poor and hardcoded estimate
			IF_GB_TR_ON(3,{printf("mm_plan_SS_DoGC prevTotalSz=%x curUsedSz=%x percentageFree=%d newTotalSz=%x\n",prevTotalSz,curUsedSz,percentageFree,prevTotalSz + (60 - percentageFree) * onePercentSz);}) ;
			if ( percentageFree < 40 ) {
				// less then some percentage of free space left, so beef it up
				Word newTotalSz = prevTotalSz + (60 - percentageFree) * onePercentSz ;
				plss->ssAllocator.setTotalSize( &plss->ssAllocator, newTotalSz ) ;
			}
		}
		res = True ;
	// } else {
	// 	res = False ;
	// }
	IF_GB_TR_ON(3,{printf("mm_plan_SS_DoGC-AFT plan=%p plss=%p\n",plan,plss);}) ;

	plss->gcProgress &= ~MM_PLAN_SS_GCPROGRESS_COLLECTING ;

	if ( ! (plss->gcProgress & MM_PLAN_SS_GCPROGRESS_POSTCOLLECTING) ) {
		plss->gcProgress |= MM_PLAN_SS_GCPROGRESS_POSTCOLLECTING ;
		plss->collector.collectPost( &plss->collector ) ;
		plss->gcProgress &= ~MM_PLAN_SS_GCPROGRESS_POSTCOLLECTING ;
	}

	return res ;
}

%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SS dump
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#ifdef TRACE
void mm_plan_SS_Dump( MM_Plan* plan ) {
	MM_Plan_SS_Data* plss = (MM_Plan_SS_Data*)plan->data ;
	
	printf( ">------------------------> MM_Plan: SS: plan=%p plss=%p\n", plan, plss ) ;

	mm_Spaces_Dump() ;
	plss->ssAllocator.dump( &plss->ssAllocator ) ;
	plss->toSpace->dump( plss->toSpace ) ;

	printf( "<------------------------< MM_Plan: SS\n" ) ;
}
#endif
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SS interface object
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
MM_Plan mm_plan_SS =
	{ NULL
	, NULL
	, &mm_plan_SS_Init
	, &mm_plan_SS_Exit
#if MM_BYPASS_PLAN
	, &mm_plan_SS_InitBypass
#endif
	, &mm_plan_SS_DoGC
%%[[90
	, &mm_plan_SS_GetWeakPtrFinalizeQue
%%]]
#ifdef TRACE
	, &mm_plan_SS_Dump
#endif
	} ;
%%]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SS test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%[8
#ifdef TRACE
void mm_plan_SS_Test() {
}
#endif
%%]


/*
 * Copyright (c) 2003, 2011, Oracle and/or its affiliates. All rights reserved.
 *
 * U.S. Government Rights - Commercial software. Government users are subject
 * to the Sun Microsystems, Inc. standard license agreement and applicable
 * provisions of the FAR and its supplements.
 *
 *
 * This distribution may include materials developed by third parties. Sun,
 * Sun Microsystems, the Sun logo and Solaris are trademarks or registered
 * trademarks of Sun Microsystems, Inc. in the U.S. and other countries.
 *
 */
#pragma ident   "@(#)entLPMappingTable.c 1.1     03/02/24 SMI"

/*
 * Note: this file originally auto-generated by mib2c using
 *        : mib2c.iterate.conf,v 5.4 2002/09/11 22:42:04 hardaker Exp $
 */

#include <net-snmp/net-snmp-config.h>
#include <net-snmp/net-snmp-includes.h>
#include <net-snmp/agent/net-snmp-agent-includes.h>
#include "stdhdr.h"
#include "entLPMappingTable.h"
#include "entLogicalTable.h"
#include "entPhysicalTable.h"
#include "entLastChangeTime.h"

typedef struct LPIndex_s {
    entLPMappingTableEntry_t *pLPEntry;
    int_l *pPhyIndex;      /* Pointer to the current phy index */
} LPIndex_t;

static LPIndex_t tracker;


entLPMappingTableEntry_t* gLPMappingTableHead;
int gLPMappingTableSize;

/*
 * Initialize the entLPMappingTable table by defining its contents and how
 * it's structured
 */
void
initialize_table_entLPMappingTable(void)
{
    static oid entLPMappingTable_oid[] = { 1, 3, 6, 1, 2, 1, 47, 1, 3, 1 };
    netsnmp_table_registration_info *table_info;
    netsnmp_handler_registration *my_handler;
    netsnmp_iterator_info *iinfo;

    /*
     * create the table structure itself
     */
    table_info = SNMP_MALLOC_TYPEDEF(netsnmp_table_registration_info);
    iinfo = SNMP_MALLOC_TYPEDEF(netsnmp_iterator_info);

    /*
     * if your table is read only, it's easiest to change the
     * HANDLER_CAN_RWRITE definition below to HANDLER_CAN_RONLY
     */
    my_handler =
        netsnmp_create_handler_registration("entLPMappingTable",
                                            entLPMappingTable_handler, entLPMappingTable_oid,
                                            OID_LENGTH(entLPMappingTable_oid), HANDLER_CAN_RONLY);

    if (!my_handler || !table_info || !iinfo)
        return;		/* mallocs failed */

    /*
     * Setting up the table's definition
     */
    netsnmp_table_helper_add_indexes(table_info,
                                     ASN_INTEGER,	/* index: entLogicalIndex */
                                     ASN_INTEGER,	/* index: entLPPhysicalIndex */
                                     0);

    table_info->min_column = 1;
    table_info->max_column = 1;

    /*
     * iterator access routines
     */
    iinfo->get_first_data_point = entLPMappingTable_get_first_data_point;
    iinfo->get_next_data_point = entLPMappingTable_get_next_data_point;

    iinfo->table_reginfo = table_info;

    /*
     * registering the table with the master agent
     */
    DEBUGMSGTL(("initialize_table_entLPMappingTable",
		"Registering table entLPMappingTable as a table iterator\n"));
    netsnmp_register_table_iterator(my_handler, iinfo);
}

/* Initializes the entLPMappingTable module */
void
init_entLPMappingTable(void)
{

    /*
     * here we initialize all the tables we're planning on supporting
     */
    initialize_table_entLPMappingTable();
    gLPMappingTableSize = 0;
    gLPMappingTableHead = NULL;
}

/*
 * returns the first data point within the entLPMappingTable table data.
 *
 *  Set the my_loop_context variable to the first data point structure
 *  of your choice (from which you can find the next one).  This could
 *  be anything from the first node in a linked list, to an integer
 *  pointer containing the beginning of an array variable.
 *
 *  Set the my_data_context variable to something to be returned to
 *  you later that will provide you with the data to return in a given
 *  row.  This could be the same pointer as what my_loop_context is
 *  set to, or something different.
 *
 *  The put_index_data variable contains a list of snmp variable
 *  bindings, one for each index in your table.  Set the values of
 *  each appropriately according to the data matching the first row
 *  and return the put_index_data variable at the end of the function.
 */
netsnmp_variable_list *
entLPMappingTable_get_first_data_point(void **my_loop_context,
                                       void **my_data_context, netsnmp_variable_list * put_index_data,
                                       netsnmp_iterator_info * mydata)
{
    netsnmp_variable_list *vptr;
    entLPMappingTableEntry_t *zRunner, *zpValidEntry;
    int_l *zPhyIndexes, zValidPhyIdx=0, *zpValidPhyIdx;

    zRunner = gLPMappingTableHead;
    while (zRunner) {
        if (zRunner->entLogicalIndex > 0) {
            zPhyIndexes = zRunner->physicalIndexes;
            while ((zPhyIndexes != NULL) && (*zPhyIndexes != 0)){
                if (*zPhyIndexes > 0) {
                    zValidPhyIdx = *zPhyIndexes;
                    break;
                }
                zPhyIndexes++;
            }
            if (zValidPhyIdx) {
                zpValidEntry = zRunner;
                zpValidPhyIdx = zPhyIndexes;
                break;
            }
        }
        zRunner = zRunner->pNextLPMappingTableEntry;
    }
    if (zRunner == NULL) return NULL;

    *my_loop_context = (void *) zpValidEntry;
    *my_data_context = (void *) zpValidPhyIdx;
    tracker.pPhyIndex = zpValidPhyIdx;

    vptr = put_index_data;

    snmp_set_var_value(vptr, (u_char *) &zpValidEntry->entLogicalIndex,
                       sizeof(zpValidEntry->entLogicalIndex));
    vptr = vptr->next_variable;
    snmp_set_var_value(vptr, (u_char *) zpValidPhyIdx, sizeof(int_l));
    vptr = vptr->next_variable;

    return (put_index_data);
}

/*
 * functionally the same as entLPMappingTable_get_first_data_point, but
 * my_loop_context has already been set to a previous value and should
 * be updated to the next in the list.  For example, if it was a
 * linked list, you might want to cast it and the return
 * my_loop_context->next.  The my_data_context pointer should be set
 * to something you need later and the indexes in put_index_data
 * updated again.
 */

netsnmp_variable_list *
entLPMappingTable_get_next_data_point(void **my_loop_context,
                                      void **my_data_context, netsnmp_variable_list * put_index_data,
                                      netsnmp_iterator_info * mydata)
{
    netsnmp_variable_list *vptr;
    entLPMappingTableEntry_t *zRunner, *zpValidEntry;
    int_l *zPhyIndexes, zValidPhyIdx=0, *zpValidPhyIdx;

    zRunner = (entLPMappingTableEntry_t *)*my_loop_context;
    zPhyIndexes =  tracker.pPhyIndex;
    if (zPhyIndexes != NULL)
        zPhyIndexes++;
    while (zRunner) {
        if (zRunner->entLogicalIndex > 0) {
            while ((zPhyIndexes != NULL) && (*zPhyIndexes != 0)){
                if (*zPhyIndexes > 0) {
                    zValidPhyIdx = *zPhyIndexes;
                    break;
                }
                zPhyIndexes++;
            }
            if (zValidPhyIdx) {
                zpValidEntry = zRunner;
                zpValidPhyIdx = zPhyIndexes;
                break;
            }
        }
        zRunner = zRunner->pNextLPMappingTableEntry;
        if (zRunner)
            zPhyIndexes = zRunner->physicalIndexes;
    }
    if (zRunner == NULL) return NULL;


    *my_loop_context = (void *) zpValidEntry;
    *my_data_context = (void *) zpValidPhyIdx;
    tracker.pPhyIndex =  zpValidPhyIdx;

    vptr = put_index_data;

    snmp_set_var_value(vptr, (u_char *) &zpValidEntry->entLogicalIndex,
                       sizeof(int_l));
    vptr = vptr->next_variable;
    snmp_set_var_value(vptr, (u_char *) zpValidPhyIdx, sizeof(int_l));
    vptr = vptr->next_variable;

    return (put_index_data);
}

/*
 * handles requests for the entLPMappingTable table, if anything else
 * needs to be done
 */
int
entLPMappingTable_handler(netsnmp_mib_handler * handler,
                          netsnmp_handler_registration * reginfo,
                          netsnmp_agent_request_info * reqinfo, netsnmp_request_info * requests)
{
    netsnmp_request_info *request;
    netsnmp_table_request_info *table_info;
    netsnmp_variable_list *var;
    int_l *idx;

    for (request = requests; request; request = request->next) {
        var = request->requestvb;
        if (request->processed != 0)
            continue;

        /*
         * perform anything here that you need to do.  The request have
         * already been processed by the master table_dataset handler,
         * but this gives you chance to act on the request in some
         * other way if need be.
         */

        /*
         * the following extracts the my_data_context pointer set in
         * the loop functions above.  You can then use the results to
         * help return data for the columns of the entLPMappingTable
         * table in question
         */
        /*
         * XXX
         */
        idx = (int_l *) netsnmp_extract_iterator_context(request);
        if (idx == NULL) {
            if (reqinfo->mode == MODE_GET) {
                netsnmp_set_request_error(reqinfo, request,
                                          SNMP_NOSUCHINSTANCE);
                continue;
            }
            /*
             * XXX: no row existed, if you support creation and
             * this is a set, start dealing with it here, else
             * continue
             */
        }

        /*
         * extracts the information about the table from the request
         */
        table_info = netsnmp_extract_table_info(request);
        /*
         * table_info->colnum contains the column number requested
         */
        /*
         * table_info->indexes contains a linked list of snmp variable
         * bindings for the indexes of the table.  Values in the list
         * have been set corresponding to the indexes of the
         * request
         */
        if (table_info == NULL) {
            continue;
        }

        switch (reqinfo->mode) {
            /*
             * the table_iterator helper should change all GETNEXTs
             * into GETs for you automatically, so you don't have to
             * worry about the GETNEXT case. Only GETs and SETs need
             * to be dealt with here
             */
        case MODE_GET:
            switch (table_info->colnum) {
            case COLUMN_ENTLPPHYSICALINDEX:
                snmp_set_var_typed_value(var, ASN_INTEGER,
                                         (u_char *) idx,
                                         sizeof (idx));
                break;

            default:
				/*
				 * We shouldn't get here
				 */
                snmp_log(LOG_ERR, "problem encountered in entLPMappingTable_handler: unknown column\n");
            }
            break;

        case MODE_SET_RESERVE1:
            /*
             * set handling...
             */

        default:
            snmp_log(LOG_ERR, "problem encountered in entLPMappingTable_handler: unsupported mode\n");
        }
    }
    return (SNMP_ERR_NOERROR);
}

/* Return 0 for success
   1 for entry already exists
   -1 for failure
   -2 for stale index */
int
addLPMappingTableEntry(int xentLogicalIndex, int xentPhysicalIndex)
{
    entLogicalEntry_t *zLogicalEntry; 
    entPhysicalEntry_t *physentry;
    entLPMappingTableEntry_t *zLPMappingTableEntry, *zRunner, *zlastEntry;
    int_l *zPhyIndexes;

    /* Fix for 4888088: return -1 for out of bound index, return -2 for */
    /*                  stale entry */
    if (xentLogicalIndex <= 0 || xentLogicalIndex > MAX_ENTITY_INDEX || xentPhysicalIndex <= 0 || xentPhysicalIndex > MAX_ENTITY_INDEX)
        return -1;
    zLogicalEntry = getLogicalTableStaleEntry(xentLogicalIndex); 
    physentry = getPhysicalTableStaleEntry(xentPhysicalIndex);
    if ((zLogicalEntry != NULL) || (physentry != NULL)) {
        return -2;
    }
    /* End of Fix for 4888088 */

    zLogicalEntry = getLogicalTableEntry(xentLogicalIndex); 
    physentry = getPhysicalTableEntry(xentPhysicalIndex);

    if ((zLogicalEntry == NULL) || (physentry == NULL)) {
/* 
   Handle error here. Send it to log files
*/
        return (-1);
    }
    zlastEntry = NULL;
    zRunner = gLPMappingTableHead;
    while (zRunner != NULL) {
        if (zRunner->entLogicalIndex == xentLogicalIndex) {
            break;
        }
        zlastEntry = zRunner;
        zRunner = zRunner->pNextLPMappingTableEntry;
    }
    if (zRunner != NULL ) {/* Found a entry with log index */
        int_l *p; 
        p = zRunner->physicalIndexes;
        if (p == NULL) {
	    zPhyIndexes = (int_l *) malloc(2 * sizeof (int_l));
	    if (!zPhyIndexes) return -1;
	    zPhyIndexes[0] = xentPhysicalIndex;
            zPhyIndexes[1] = 0;
	    zRunner->physicalIndexes = zPhyIndexes;
        } else {/* Add phy index to last entry in the array */
            int i=0;
	    while (p != NULL && *p != 0) {
                /* Fix for 4888088: entry already exists, return 1 */
		if (*p == xentPhysicalIndex)
                    return (1);
                /* End of Fix for 4888088 */
		if (*p == -xentPhysicalIndex) { /* Reuse a 'deleted' entry */
		    *p = xentPhysicalIndex;
                    /* Fix for 4928821 - does not generate notification event */
                    configChanged();
                    /* End of Fix for 4928821 */
	            return (0);
		}
	        p++;
		i++;
	    }
	    zRunner->physicalIndexes = 
	        (int_l *)realloc(zRunner->physicalIndexes, (i + 2)*sizeof(int_l));
	    zRunner->physicalIndexes[i] = xentPhysicalIndex;
	    zRunner->physicalIndexes[i+1] = 0;
        }
        configChanged();
        return (0);
    } 

    /* New entry*/
    zLPMappingTableEntry = (entLPMappingTableEntry_t *)malloc(sizeof(entLPMappingTableEntry_t));
    if (!zLPMappingTableEntry) return -1; /* malloc failed */
    zLPMappingTableEntry->entLogicalIndex = xentLogicalIndex;
    zPhyIndexes = (int_l *) malloc(2 * sizeof (int_l));
    if (!zPhyIndexes) return -1;
    zPhyIndexes[0] = xentPhysicalIndex;
    zPhyIndexes[1] = 0;
    zLPMappingTableEntry->physicalIndexes = zPhyIndexes;
    zLPMappingTableEntry->pNextLPMappingTableEntry = NULL;
    if (gLPMappingTableHead){
        zlastEntry->pNextLPMappingTableEntry = zLPMappingTableEntry;
    } else {
        gLPMappingTableHead = zLPMappingTableEntry;
    }
    gLPMappingTableSize++;
    configChanged();
    return (0);
}


/*
  This function deletes the table entries for a given logical index
  and physical index. 
  Returns 0 for success,
  -1 for failure,
  -2 for stale entry
 */
int
deleteLPMappingTableEntry(int xentLogicalIndex, int xentPhysicalIndex)
{
    entLPMappingTableEntry_t *zRunner;
    int_l *p;

    /* Fix for 4888088: return -1 for invalid index, -2 for stale entry */
    entLogicalEntry_t *zLogicalEntry;
    entPhysicalEntry_t *zPhysicalEntry;

    if (xentLogicalIndex <= 0 || xentLogicalIndex > MAX_ENTITY_INDEX || xentPhysicalIndex <= 0 || xentPhysicalIndex > MAX_ENTITY_INDEX)
        return -1;
    zLogicalEntry = getLogicalTableStaleEntry(xentLogicalIndex);
    if (zLogicalEntry != NULL)
        return -2;

    zPhysicalEntry = getPhysicalTableStaleEntry(xentPhysicalIndex);
    if (zPhysicalEntry != NULL)
        return -2;

    zLogicalEntry = getLogicalTableEntry(xentLogicalIndex);
    if (zLogicalEntry == NULL)
        return -1;
    zPhysicalEntry = getPhysicalTableEntry(xentPhysicalIndex);
    if (zPhysicalEntry == NULL)
        return -1;
    /* End of Fix for 4888088 */

    zRunner = gLPMappingTableHead;
    while (zRunner != NULL) {
        if ((zRunner->entLogicalIndex == xentLogicalIndex)) {
            p = zRunner->physicalIndexes;
            while (p != NULL && *p != 0) {
                if (*p == xentPhysicalIndex) {
                    *p = -xentPhysicalIndex;
                    configChanged();
                    return (0);
                }
                p++;
            }
            return (-1);
        }
        zRunner = zRunner->pNextLPMappingTableEntry;
    }
    return (-1);
}

static int 
FreeLPMappingTableEntry(entLPMappingTableEntry_t *xEntry)
{
    int nFound = 0;
    /* Fix for 4888088 */
    int_l *zPhyIndexes;
    /* End of Fix for 4888088 */

    if (xEntry == NULL) return (-1);
    /* Fix for 4888088: We need to count the number of entries deleted, and */
    /*                  return that accordingly.  Hence the loop */
    zPhyIndexes = xEntry->physicalIndexes;
    while ((zPhyIndexes != NULL) && (*zPhyIndexes != 0)) {
        if (*zPhyIndexes > 0) {
            /* Only count valid entries (i.e. non-negative ones) */
            nFound++;
        }
        zPhyIndexes++;
    }
    /* End of Fix for 4888088 */
    free(xEntry->physicalIndexes);
    free(xEntry);
    xEntry = NULL;
    /* Fix for 4888088 */
    return (nFound);
    /* End of Fix for 4888088 */
}

/* Returns num of successful deletion
   -1 for entry not found
   -2 for stale physical entry
*/
int
deleteLPMappingPhysicalIndex(int xentPhysicalIndex) {
    entLPMappingTableEntry_t *zRunner;
    int_l *p;
    int num=0;

    /* Fix for 4888088: -2 for stale entry, -1 for invalid index */
    entPhysicalEntry_t *zPhysicalEntry;
    if (xentPhysicalIndex <= 0 || xentPhysicalIndex > MAX_ENTITY_INDEX)
        return -1;
    zPhysicalEntry = getPhysicalTableStaleEntry(xentPhysicalIndex);
    if (zPhysicalEntry != NULL)
        return -2;
    zPhysicalEntry = getPhysicalTableEntry(xentPhysicalIndex);
    if (zPhysicalEntry == NULL)
        return -1;
    /* End of Fix for 4888088 */

    zRunner = gLPMappingTableHead;
    while (zRunner != NULL) {
        p = zRunner->physicalIndexes;
        while (p != NULL && *p != 0) {
            if (*p == xentPhysicalIndex) {
                *p = -xentPhysicalIndex;
                num++;
                break;
            }
            p++;
        }
        zRunner = zRunner->pNextLPMappingTableEntry;
    }
    if (num) {
        configChanged();
        return (num);
    } else {
        return -1;
    }
}

/* Returns num of successful deletion
   -1 for entry not found
   -2 for stale logical entry
*/
int
deleteLPMappingLogicalIndex(int xentLogicalIndex) {
    entLPMappingTableEntry_t *zRunner, *temp, *prevEntry;
    int zLogicalIndex, nEntries=0;

    /* Fix for 4888088: -1 for invalid index, -2 for stale entry */
    entLogicalEntry_t *zLogicalEntry;
    if (xentLogicalIndex <= 0 || xentLogicalIndex > MAX_ENTITY_INDEX)
        return -1;
    zLogicalEntry = getLogicalTableStaleEntry(xentLogicalIndex);
    if (zLogicalEntry != NULL)
        return -2;
    zLogicalEntry = getLogicalTableEntry(xentLogicalIndex);
    if (zLogicalEntry == NULL)
        return -1;
    /* End of Fix for 4888088 */

    zRunner = gLPMappingTableHead;
    prevEntry = NULL;
    while (zRunner != NULL) {
        zLogicalIndex = zRunner->entLogicalIndex;
        if (zLogicalIndex > 0) {
            if (zLogicalIndex == xentLogicalIndex) {
                temp =  zRunner->pNextLPMappingTableEntry;
                zRunner->pNextLPMappingTableEntry = NULL;
                if (prevEntry)
                    prevEntry->pNextLPMappingTableEntry = temp;
                else
                    gLPMappingTableHead = temp;
                /* Fix for 4888088: we are going to return the number of */
                /*                  entries removed */
                nEntries = FreeLPMappingTableEntry(zRunner);
                /* End of Fix for 4888088 */
                gLPMappingTableSize--;
                configChanged();
                /* Fix for 4888088 */
                return (nEntries); /* Successful deletion */
                /* End of Fix for 4888088 */
            }
        }
        prevEntry = zRunner;
        zRunner = zRunner->pNextLPMappingTableEntry;
    }
    return (-1); /* Entry not found */
} 


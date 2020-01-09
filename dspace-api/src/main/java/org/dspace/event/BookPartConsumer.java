/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.event;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.text.SimpleDateFormat;
import org.apache.commons.lang3.ArrayUtils;

import org.apache.log4j.Logger;
import org.dspace.content.*;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.event.Consumer;
import org.dspace.event.Event;
import org.dspace.core.ConfigurationManager;
import org.dspace.handle.HandleManager;
import org.dspace.utils.DSpace;

/**
 * Class for audit changes relevant for protect book and book part objects mutual referential integrity.
 *
 * @version $Revision$
 *
 * @author Marianna Muehlhoelzer (muehlhoelzer at sub.uni-goettingen.de)
 *
 */

public class BookPartConsumer implements Consumer {
    /**
     * log4j logger
     */
    private static Logger log = Logger.getLogger(BookPartConsumer.class);


    public void initialize() throws Exception {
        //No-op
    }

    /**
     * Consume a content event -- just build the sets of objects to add (new) to the
     * index, update, and delete.
     *
     * @param ctx   DSpace context
     * @param event Content event
     */
    public void consume(Context ctx, Event event) throws Exception {
        log.info("Consume active...");
        String detail = event.getDetail();
        String msg = "EVENT: called TestConsumer.consume(): EventType="
                + event.getEventTypeAsString()
                + ", SubjectType="
                + event.getSubjectTypeAsString()
                + ", SubjectID="
                + String.valueOf(event.getSubjectID())
                + ", ObjectType="
                + event.getObjectTypeAsString()
                + ", ObjectID="
                + String.valueOf(event.getObjectID())
                + ", Identifiers="
                + ArrayUtils.toString(event.getIdentifiers())
                + ", "
                + ", extraLog=\""
                + ctx.getExtraLogInfo()
                + "\""
                + ", dispatcher="
                + String.valueOf(event.getDispatcher())
                + ", detail="
                + (detail == null ? "[null]" : "\"" + detail + "\"")
                + ", transactionID="
                + (event.getTransactionID() == null ? "[null]" : "\""
                + event.getTransactionID() + "\"") + ", context="
                + ctx.toString();
        log.info(msg);
        if (event.getSubjectType() != Constants.ITEM) {
            return;
        }


        DSpaceObject dso = event.getSubject(ctx);

        if (!(dso instanceof Item)) {
            return;
        }

        Item item = (Item) dso;

        int et = event.getEventType();
        int itemID = event.getObjectID();


        if (et != Event.INSTALL) {
            return;
        }


        if (et == Event.INSTALL) {
            log.info("Installing...");
            // New bookPart is published
            if (dso.getMetadata(MetadataSchema.DC_SCHEMA, "type", null, Item.ANY)[0].value.equals("bookPart")) {
                // set the bookPart object private and
                log.info("BookPart");
                try {
                    item.setDiscoverable(false);
                    item.update();
                    String parentHandle = dso.getMetadata("dc", "relation", "ispartof", Item.ANY)[0].value;
		    String partnr = dso.getMetadata("dc", "bibliographicCitation", "chapter", Item.ANY)[0].value;

                    //add it in the parent as part
                    DSpaceObject parentdso;
                    parentdso = HandleManager.resolveToObject(ctx, parentHandle);
                    Item parentItem = (Item) parentdso;

                    parentdso.addMetadata("dc", "relation", "haspart", null, parentHandle + '.' + partnr);
                    parentItem.update();
                } catch (Exception e) {
                    log.error("Error installing Bookpart " + item.getHandle() + " as part of another book");
                    log.error(e.getMessage(), e);

                }

            }

            return;
        }

    }

    public void end(Context ctx) throws Exception {
        //No-op
    }

    public void finish(Context ctx) throws Exception {
        //No-op
    }
}


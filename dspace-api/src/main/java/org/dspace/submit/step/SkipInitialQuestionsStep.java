/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.submit.step;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.dspace.app.util.SubmissionInfo;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.InProgressSubmission;
import org.dspace.content.Item;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.submit.AbstractProcessingStep;

/**
 * This is a Simple Step class that need to be used when you want skip the
 * initial questions step!
 * <p>
 * At the moment this step is required because part of the behaviour of the
 * InitialQuestionStep is required to be managed also in the DescribeStep (see
 * JIRA [DS-83] Hardcoded behaviour of Initial question step in the submission)
 * </p>
 * 
 * @see org.dspace.submit.AbstractProcessingStep
 * @see org.dspace.submit.step.InitialQuestionsStep
 * @see org.dspace.submit.step.DescribeStep
 * 
 * @author Andrea Bollini
 * @version $Revision$
 */
public class SkipInitialQuestionsStep extends AbstractProcessingStep
{
    /**
     * Simply we flags the submission as the user had checked both multi-title,
     * multi-files and published before so that the input-form configuration
     * will be used as is
     */
    public int doProcessing(Context context, HttpServletRequest request,
            HttpServletResponse response, SubmissionInfo subInfo)
            throws ServletException, IOException, SQLException,
            AuthorizeException
    {
        InProgressSubmission submissionItem = subInfo.getSubmissionItem();
        submissionItem.setMultipleFiles(true);
        submissionItem.setMultipleTitles(true);
        submissionItem.setPublishedBefore(true);
        submissionItem.update();

        // Creators want to write the future DOI in his work, so
        // create university press DOI in advance and save it as special metadata
        Item item = submissionItem.getItem();
        System.out.println("INTERN DOI LÄNGE " + item.getMetadataByMetadataString("dc.intern.doi").length);
        if (item.getMetadataByMetadataString("dc.intern.doi").length == 0)
        {
            item.addMetadata("dc", "intern", "doi", "en", createDOI(item));
            // Save changes to database
            submissionItem.update();

        }
        return STATUS_COMPLETE;
    }

    /**
     * Create DOI based on configured prefix and namespacseparator
     * on year and itemid
     *
     * @param it
     * @return created DOI
     */
    private String createDOI(Item it)
    {
        Calendar cal = Calendar.getInstance();
        return (ConfigurationManager.getProperty("identifier.doi.prefix")
                + "/" + ConfigurationManager.getProperty("identifier.doi.namespaceseparator")
                + cal.get(Calendar.YEAR) + "-" + it.getID());

    }

    public int getNumberOfPages(HttpServletRequest request,
            SubmissionInfo subInfo) throws ServletException
    {
        return 1;
    }
}

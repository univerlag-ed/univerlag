package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.text.DecimalFormat;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.dspace.app.xmlui.utils.ContextUtil;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.core.Email;
import org.dspace.core.I18nUtil;
import javax.mail.MessagingException;
import org.apache.commons.validator.routines.EmailValidator;

import org.dspace.content.Item;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Metadatum;
import java.sql.SQLException;

import java.util.Iterator;
import java.util.Arrays;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.dspace.app.xmlui.utils.Bill;

import java.util.Locale;

/**
 * OrderAction handles product order requests.
 * Possible requests are: "order" or "costrequest".
 * required request parameter is JSON-Object as string,
 * returns JSON-Object as string
 *
 * order={
 *        "items": [
 *        {
 *        "quantity":"<anzahl>",
 *        "id":" <id>",
 *        "part": "<print | cdrom | dvd | print:n | cdrom:n | dvd:n >"
 *        },
 *        …… (optional further items)
 *        ],
 *        "customer": {
 *        "name": "<firsname lastname>",
 *        "email": "<email>",
 *        "zipcode": "<ZIP code>",
 *        "city": "<city>",
 *        "address": "<street housenumber>",
 * 		  "company": "<Uniklinik Hamburg>",
 *        "country": "<country>",
 *        “countrycode”: "<countrycode>"     //countrycode is required in case delivery not existent
 *        },
 *        "delivery": { //onlliy if customer address != delivery address
 *        "name": "<firsname lastname>",
 *        "email": "<email>",
 *        "zipcode": "<ZIP code>",
 *        "city": "<city>",
 *        "address": "<street housenumber>",
 *        "country": "<country>",
 *        “countrycode”: <countrycode>"
 *        }
 * }
 *
 * return:
 * {"success":"true"} or
 * {"success":"false"},{"error": "<errormessage>"}
 *
 *or
 *
 *costrequest={
 *     "countrycode":"<countrycode>",
 *     "items":[
 *          {
 *          "quantity":"<number>",
 *          "id":"<id>",
 *          "part":"<print | cdrom | dvd | print:n | cdrom:n | dvd:n >"
 *          }
 *          //,... optionals further items
 *      ]
 *}
 * returns price information in euro with two decimal places:
 * {"products":"<productcosts>"}
 * {"total":"<totalcosts>"}
 * {"shipping":"<shippingcosts>"}
 *
 * possible shippingcosts values:
 * any positiv amount,
 * -1.00: not calculable 
 * 0.00: discount for shipping
 *
 *
 *
 *This class checks also the existence and validity of required parameter
 * and sends confirmation email to customer and
 * notification email to order recipient.
 *
 *
 * @author Marianna Muehlhuelzer
 */

public class OrderAction extends AbstractAction
{

    /**
     *
     */


    public static final String[] partValues = {"print", "cdrom", "dvd"};
    private Bill bill = new Bill();
    JSONObject jsonResult = new JSONObject();

    public Map act(Redirector redirector, SourceResolver resolver, Map objectModel,
                   String source, Parameters parameters) throws Exception {
        Request request = ObjectModelHelper.getRequest(objectModel);

        Context context = ContextUtil.obtainContext(objectModel);

        Map<String, String> map = new HashMap<String, String>();


        JSONObject jsonObject;
        String input;
        String action;


        if (request.getParameter("order") != null) {
            input = request.getParameter("order").trim();
            action = "order";
        } else if (request.getParameter("costrequest") != null) {
            input = request.getParameter("costrequest").trim();
            action = "costrequest";
        } else {
             writeError(map, "invalid request");
            return map;

        }
        System.out.println("ORDER PARAMTER: " + input);
        //check first input validity
        try {
            JSONParser jsonParser = new JSONParser();
            jsonObject = (JSONObject) jsonParser.parse(input);

        } catch (ParseException pe) {
            //troubles with parameter parsing

            //Syntax error
            System.out.println("position: " + pe.getPosition());
            System.out.println(pe);
            writeError(map, "position: " + pe.getPosition() + pe);
            System.out.println(jsonResult.toJSONString());
            return map;

        } catch (NullPointerException npe) {

            //missing some parameter
            writeError(map, "Missing parameter");
            System.out.println(jsonResult.toJSONString());
            return map;

        }

        //handle paramter items which is common in both requests
        JSONArray items = (JSONArray) jsonObject.get("items");
        JSONObject item = null;
        Item dsitem = null;
        Iterator it = items.iterator();
        String countrycode = "DE";  //default is Germany
        //container for temporary infos
        StringBuilder temp_data = new StringBuilder();

        System.out.println("Inspecting items... ");
        if (!it.hasNext()) { writeError(map, "no items"); return map;}

        while (it.hasNext()) {
            item = (JSONObject) it.next();


            //Check item attributes
            String quantity = (String) item.get("quantity");
            String id = (String) item.get("id");
            String parts = (String) item.get("part");

            if ((id == null) || id.equals("")) {
                writeError(map, "missing id");
                System.out.println(jsonResult.toJSONString());
                return map;
            }

            if ((quantity == null) || quantity.equals("")) {
                writeError(map, "Missing quantity for item " + id);
                System.out.println(jsonResult.toJSONString());
                return map;
            }

            if ((parts == null) || parts.equals("")) {
                writeError(map, "Missing part of item " + id);
                System.out.println(jsonResult.toJSONString());
                return map;
            }

            System.out.println("Item params ok...");
            //item params ok, check id
            if (Integer.parseInt(quantity) > 0) {

                try {
                    dsitem = (Item) DSpaceObject.find(context, 2, Integer.parseInt((String) item.get("id")));

                } catch (SQLException se) {
                    writeError(map, "DB access");
                    System.out.println(jsonResult.toJSONString());
                    return map;
                }
                if (dsitem == null) {
                    writeError(map, "Invalid id " + id);
                    return map;
                }
                System.out.println("Getting DCValues...");
                //get data for costs
                Metadatum[] metadata;

                int ind = (parts.indexOf(":") > -1) ? Integer.parseInt(parts.substring(parts.indexOf(":") + 1)) : 0;
                String part = (parts.indexOf(":") > -1) ? parts.substring(0, parts.indexOf(":")) : parts;


                //Check part validity

                if (!Arrays.asList(partValues).contains(part)) {
                    writeError(map, "invalid part");
                    return map;
                }


                String extent = (part.equals("print")) ? (dsitem.getMetadata("dc", "format", "extent", Item.ANY)[ind].value) : "0";
                String price = dsitem.getMetadata("dc", "price", part, Item.ANY)[ind].value;

                //Check price and extent for print
                if ((extent == null) || extent.equals("")
                        || (price == null) || price.equals("")) {
                    writeError(map, "No size or price found for item " + id);
                    System.out.println(jsonResult.toJSONString());
                    return map;
                } else {

                    bill.addWeight(quantity, extent);
                    bill.addPrice(quantity, price);
                }
                System.out.println("quantity: " + quantity);
                System.out.println("extent: " + extent);
                System.out.println("checking request...");
                //for order only
                if (action.equals("order")) {
                    System.out.println("order request!");
                    temp_data.append(quantity);
                    temp_data.append("x à ");
                    temp_data.append(price);
                    temp_data.append("\n");

                    //get creators
                    if (dsitem.getMetadata("dc", "contributor", "author", Item.ANY).length > 0) {
                        metadata = dsitem.getMetadata("dc", "contributor", "author", Item.ANY);
                    } else {
                        metadata = dsitem.getMetadata("dc", "contributor", "editor", Item.ANY);
                    }


                    for (int j = 0; j < metadata.length; j++) {
                        temp_data.append(metadata[j].value);
                        if (j < (metadata.length - 1)) {
                            temp_data.append("; ");
                        }
                    }
                    temp_data.append("\n");

                    //get title
                    temp_data.append(dsitem.getMetadata("dc", "title", null, Item.ANY)[0].value);
                    temp_data.append("\n");

                    //get description
                    if (part.equals("print")) {
                        temp_data.append(dsitem.getMetadata("dc", "description", part, Item.ANY)[ind].value);

                    }
                    else if (part.equals("cdrom")){
                        temp_data.append("CDROM");
                    }
                    else if(part.equals("dvd"))
                    {
                        temp_data.append("DVD-Video");
                    }
                    else {
                        writeError(map, "invalid part");
                        return map;
                    }
                    temp_data.append("\n");


                    //get ISBN if existent
                    if (dsitem.getMetadata("dc", "relation", "isbn-13", Item.ANY).length > 0) {
                        temp_data.append("ISBN: ");
                        temp_data.append(dsitem.getMetadata("dc", "relation", "isbn-13", Item.ANY)[0].value);
                    } else if (dsitem.getMetadata("dc", "relation", "isbn", Item.ANY).length > 0) {
                        temp_data.append("ISBN: ");
                        temp_data.append(dsitem.getMetadata("dc", "relation", "isbn", Item.ANY)[0].value);
                    }

                    temp_data.append("\n\n");
                }
            }//quantitiy > 0
        }//end while


        if (action.equals("costrequest")) {
	    countrycode = (String) jsonObject.get("countrycode");
            System.out.println("cost request!");
            if (jsonObject.get("countrycode") == null) {
                jsonResult.put("shipping", "false");

            } else {
                System.out.println("calculating shipping costs...");

                jsonResult.put("products", bill.getProductCost());
                jsonResult.put("shipping", bill.getShippingCost(countrycode));
                jsonResult.put("total", bill.getTotalSum(countrycode));
            }
            System.out.println("Costrequest finished!! Result: " + jsonResult.toJSONString());
            map.put("result", jsonResult.toJSONString());

            return map;
        }

        if (action.equals("order")) {
            if (bill.getProductCost().equals("0.00")) {
                // null or negative number of items ordered
                writeError(map, "no items ordered");
                return map;
            }
            System.out.println("preparing email info...");
            //email parameter
	    
            String customer_email;
            String customer_info;
            String delivery_info;
            String order_data;
            String shipping_cost = "";
            String total_sum = bill.getTotalSum(countrycode);
			String formvariant = "_complete";
			String customer_locale = "DE";
			
            //Order data complete. Write them in email parameter and empty the container
            order_data = temp_data.toString();
            temp_data.delete(0, temp_data.length());

            //get customer infos and validate them
            //validate data and return with error message if necessary
            JSONObject customer = (JSONObject) jsonObject.get("customer");
            if (customer == null) {
                writeError(map, "Missing customer");
                System.out.println(jsonResult.toJSONString());
                return map;
            }

            customer_email = (String) customer.get("email");

            EmailValidator ev = EmailValidator.getInstance();

            System.out.println("Checking customer...");


            if ((customer_email.equals("")) || (!ev.isValid(customer_email))) {
                writeError(map, "Invalid email");
                map.put("result", jsonResult.toJSONString());
                System.out.println(jsonResult.toJSONString());
                return map;
            }

            if ( ((customer.get("name") == null) &&  (customer.get("company") == null)) || (customer.get("address") == null)
                    || (customer.get("zipcode") == null) || (customer.get("city") == null)
                    || (customer.get("country") == null)) {
                writeError(map, "incomplete customer info");
                System.out.println(jsonResult.toJSONString());
                return map;
            } else {
                System.out.println("data complete!");
                //customer data complete
                if (customer.get("name") != null) {
					temp_data.append((String) customer.get("name"));
					temp_data.append("\n");
				}
				if (customer.get("company") != null) {
					temp_data.append((String) customer.get("company"));
					temp_data.append("\n");
				}
                temp_data.append((String) customer.get("address"));
                temp_data.append("\n");
                temp_data.append((String) customer.get("zipcode"));
                temp_data.append(" ");
                temp_data.append((String) customer.get("city"));
                temp_data.append("\n");
                temp_data.append((String) customer.get("country"));	
                temp_data.append("\n");
                if (!customer_locale.equals((String) customer.get("countrycode")))
				{
						customer_locale = "en";
				}
		else {
				customer_locale = "de";
			}
            }
            //Customer info complete. Write them in email parameter and empty the container.
            customer_info = temp_data.toString();
            temp_data.delete(0, temp_data.length());

            System.out.println("Checking delivery...");
            //get delivery info and validate them if existent
            if ((JSONObject) jsonObject.get("delivery") != null) {

                JSONObject delivery = (JSONObject) jsonObject.get("delivery");
                countrycode = (String) delivery.get("countrycode");

                if ( ((delivery.get("name") == null) && (delivery.get("company") == null)) || (delivery.get("address") == null)
                        || (delivery.get("zipcode") == null) || (delivery.get("city") == null)
                        || (delivery.get("country") == null) || (countrycode == null) || countrycode.equals("")) {
                    jsonResult.put("success", "false");
                    jsonResult.put("error", "incomplete delivery info");
                    map.put("result", jsonResult.toJSONString());
                    writeError(map, "incomplete delivery info");
                    System.out.println(jsonResult.toJSONString());
                    return map;
                } else //delivery data complete
                {
                    System.out.println("data complete!");
                    if (delivery.get("name") != null )
                    {
						temp_data.append((String) delivery.get("name"));
						temp_data.append("\n");
					}
					if (delivery.get("company") != null )
                    {
						temp_data.append((String) delivery.get("company"));
						temp_data.append("\n");
					}
                    temp_data.append((String) delivery.get("address"));
                    temp_data.append("\n");
                    temp_data.append((String) delivery.get("zipcode"));
                    temp_data.append(" ");
                    temp_data.append((String) delivery.get("city"));
                    temp_data.append("\n");
                    temp_data.append((String) delivery.get("country"));
                    temp_data.append("\n");

                    delivery_info = temp_data.toString();
                    temp_data.delete(0, temp_data.length());
                }

            } else {
                //delivery address = customer address

                System.out.println("identical with customer");
                countrycode = (String) customer.get("countrycode");
                if ((countrycode == null) || countrycode.equals("")) {
                    writeError(map, "missing countrycode");
                    return map;
                }
                delivery_info = customer_info;
            }
            System.out.println("Checking bill data...");
            
            shipping_cost = bill.getShippingCost(countrycode);
            if (bill.getShippingCost(countrycode).startsWith("-1"))  {
					/*shipping_cost_en += "Information on demand.";
					shipping_cost_de += "Information auf Anfrage.";
                    total_sum_en += " plus shipping costs";
					total_sum_de += " zzgl. Versandkosten";*/
					formvariant = "";

            } 
            System.out.println("calculating shipping costs...");


            // set parameter for confirmation email to customer
            System.out.println("setting confirmation email parameter...");
            
            /**Email confirm_email = Email.getEmail("order_confirm" + formvariant + "_" + customer_locale); **/
	    Email confirm_email = Email.getEmail(I18nUtil.getEmailFilename(new Locale(customer_locale), "order_confirm" + formvariant ));
            DecimalFormat df = new DecimalFormat("##0.00");
            System.out.println("Locale: " + context.getCurrentLocale());
            int product = Integer.parseInt(bill.getProductCost().replace('.', '.'));
            int shipping = Integer.parseInt(shipping_cost.replace('.', '.'));
            total_sum = df.format((product + shipping)/100.00);
            confirm_email.addRecipient(customer_email);
            confirm_email.addArgument(new Date());
            confirm_email.addArgument(customer_email);
            confirm_email.addArgument(customer_info);                        //customer name, address, zipcode, city, country
            confirm_email.addArgument(delivery_info);                        //delivery address with name, address, zipcode, city, country
            confirm_email.addArgument(order_data);                            //ordered product info: price, quantitiy, creators, title, description, isbn
	    System.out.println("email product cost: "+ df.format(product/100.00));
            confirm_email.addArgument(df.format(product/100.00));                //price sum of ordered products
	     System.out.println("email shiping cost: "+ shipping_cost);
            confirm_email.addArgument(shipping_cost);                        //costs for shipping
	      System.out.println("email total sum: "+ total_sum);
            confirm_email.addArgument(total_sum);                           //total amount to pay


            //send confirmation email
            System.out.println("Confirm email....");
            try {
                System.out.println("try to send...");
                confirm_email.send();
                System.out.println("should be OK!");
            } catch (MessagingException me) {
                writeError(map, "confirmation email failed");
                System.out.println(jsonResult.toJSONString());
                return map;
            }


            //send parameter for email to order recipient
            Email email = Email.getEmail(I18nUtil.getEmailFilename(context.getCurrentLocale(),"order" + formvariant));
            email.addRecipient(ConfigurationManager.getProperty("order.recipient"));

            email.addArgument(new Date());
            email.addArgument(customer_email);
            email.addArgument(customer_info);
            email.addArgument(delivery_info);
            email.addArgument(order_data);
            email.addArgument(df.format(product/100.00));
            email.addArgument(shipping_cost);
            email.addArgument(total_sum);

            //send email to order recipient
            try {
                email.send();
                // everything ok and emails sent


            } catch (MessagingException me) {
                writeError(map, "notification email failed");
                System.out.println(jsonResult.toJSONString());
                return map;
            }


            System.out.println("Orderrequest finished!!");
            jsonResult.put("success", "true");
            map.put("result", jsonResult.toJSONString());
            System.out.println(jsonResult.toJSONString());
            return map;
        }

        //if we are here request is not valid
        writeError(map, "invalid request");
        return map;
    }

    private void writeError(Map<String, String> resultmap, String errorMessage) {
        jsonResult.put("success", "false");
        jsonResult.put("error", errorMessage);
        resultmap.put("result", jsonResult.toJSONString());
    }

}


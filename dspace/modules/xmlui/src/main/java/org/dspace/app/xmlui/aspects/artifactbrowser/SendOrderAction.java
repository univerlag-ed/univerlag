/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.artifactbrowser;

import java.net.InetAddress;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.dspace.app.xmlui.utils.ContextUtil;
//import org.dspace.authorize.AuthorizeException;
import org.dspace.core.ConfigurationManager;
import org.dspace.core.Context;
import org.dspace.core.Email;
import org.dspace.core.I18nUtil;
import javax.mail.MessagingException;
import org.apache.commons.validator.routines.EmailValidator;

import org.dspace.content.Item;
import org.dspace.content.DSpaceObject;
import org.dspace.content.DCValue;
import java.sql.SQLException;

import java.util.Iterator;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.dspace.handle.HandleManager;

import java.net.URLDecoder;

/**
 * @author Marianna Muehlhuelzer
 */

public class SendOrderAction extends AbstractAction
{

    /**
     *
     */
    public Map act(Redirector redirector, SourceResolver resolver, Map objectModel,
            String source, Parameters parameters) throws Exception
    {
        Request request = ObjectModelHelper.getRequest(objectModel);

        Context context = ContextUtil.obtainContext(objectModel);

		
        String order  = request.getParameter("order").trim();
		System.out.println("ORDER PARAMTER: " + order);
	
		Map<String,String> map = new HashMap<String,String>();
		JSONObject jsonResult = new JSONObject();
		
		//parse JSONString
		try {
			JSONParser jsonParser = new JSONParser();
			JSONObject jsonObject = (JSONObject) jsonParser.parse(order);
			JSONObject customer = (JSONObject) jsonObject.get("customer");
			String customer_email = (String) customer.get("email");			
			//get order info
			
			//items
			JSONArray items = (JSONArray) jsonObject.get("items");
			StringBuilder temp_data = new StringBuilder();
			
			JSONObject item;
			Item dsitem;
			Iterator i = items.iterator();
			boolean valid = true;
			String price;
			int sum = 0;
			String total_sum;

			
			while (i.hasNext() && valid) {
				item = (JSONObject) i.next();
				
				//check id
				try 
				{
					dsitem = (Item) DSpaceObject.find(context, 2, Integer.parseInt((String) item.get("id")));
				}
				catch (SQLException se)
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "invalid item");
					jsonResult.put("value", (String) item.get("id"));
					map.put("result", jsonResult.toJSONString());     
					System.out.println(jsonResult.toJSONString()); return map;
				}
				
				//id is ok
				if ((String) item.get("quantity") != null)
				{
					temp_data.append((String) item.get("quantity"));
					temp_data.append("x à ");
				}
				else 
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "missing quantity");
					map.put("result", jsonResult.toJSONString());     
					System.out.println(jsonResult.toJSONString()); return map;
				}
				int q = Integer.parseInt((String) item.get("quantity"));
								
				
				//lookup item data and compare description
				String desc = URLDecoder.decode((String) item.get("description"), "UTF-8");
				//String desc = (String) item.get("description");
				
				DCValue[] dcvalues;
				/*if ((String) item.get("description") != null) {
					desc = (String) item.get("description");
				}*/
				
				//print order is most likely
				if (desc.indexOf("CD-ROM: ") == -1 && (desc.indexOf("DVD-Video: ") == -1))
				{
					dcvalues = dsitem.getMetadata("dc", "description", "print", Item.ANY);
				}
				
				else if (desc.indexOf("CD-ROM: ") > -1)
				{
					dcvalues = dsitem.getMetadata("dc", "description", "cdrom", Item.ANY);				
				}
				else if (desc.indexOf("DVD-Video: ") > -1) {
					dcvalues = dsitem.getMetadata("dc", "description", "dvd", Item.ANY);
					//add 3 Euro forwarding charge
					sum += 3;
				}
				else 
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "no description found to item with ID: " + (String) item.get("id"));
					map.put("result", jsonResult.toJSONString());     
					System.out.println(jsonResult.toJSONString()); return map;
				}
				//check if item can be ordered
				if (desc.indexOf("€") == -1)
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "item not available for sale");
					map.put("result", jsonResult.toJSONString());     
					System.out.println(jsonResult.toJSONString()); return map;
				}
				
				boolean found = false;
				int j = 0;
				while (j < dcvalues.length && !found)
				{
						if (dcvalues[j].value.equals(desc))
						{
							found = true;
						}				
						j++;
				}	
				if (!found) 
				{ 
					jsonResult.put("success", "false");
					jsonResult.put("error", "no item found with description: " + (String) item.get("description"));
					map.put("result", jsonResult.toJSONString());     
					System.out.println(jsonResult.toJSONString()); return map;
				}
				//item and descr. ok
								
				//get price
				System.out.println("Quantity " + Integer.toString(q));
				
				if (desc.indexOf(": ") > -1) 
				{
					price = desc.substring(desc.indexOf(": ") + 2);
					temp_data.append(price);
					temp_data.append("\n\n");
					
					//Add price to sum
					System.out.println("Preis " + price);
					sum += q * Integer.parseInt(price.substring(0, price.indexOf(",00")));
					System.out.println("Quantity " + Integer.toString(q));
					System.out.println("Preis " + Integer.toString(sum));
				}	
				else 
				{
					System.out.println("Preis not found");
				}
				 
				//get creators 
				if (dsitem.getMetadata("dc", "contributor", "author", Item.ANY).length > 0)
				{
					dcvalues = dsitem.getMetadata("dc", "contributor", "author", Item.ANY);
				}
				else
				{
					dcvalues = dsitem.getMetadata("dc", "contributor", "editor", Item.ANY);
				}
				
				
				for (j=0; j < dcvalues.length; j++)
				{
					temp_data.append(dcvalues[j].value);
					if (j < (dcvalues.length -1)) {
						temp_data.append("; ");
					}
				}
				temp_data.append("\n");
				
				//get title
				temp_data.append(dsitem.getMetadata("dc", "title", null, Item.ANY)[0].value);
				temp_data.append("\n");
				temp_data.append(desc.substring(0, desc.indexOf(": ")));
				temp_data.append("\n");
				
				
				//get ISBN if existent
				if (dsitem.getMetadata("dc", "relation", "isbn-13", Item.ANY).length > 0)
				{
					temp_data.append("ISBN: ");
					temp_data.append(dsitem.getMetadata("dc", "relation", "isbn-13", Item.ANY)[0].value);
				}
				else if (dsitem.getMetadata("dc", "relation", "isbn", Item.ANY).length > 0)
				{
					temp_data.append("ISBN: ");
					temp_data.append(dsitem.getMetadata("dc", "relation", "isbn", Item.ANY)[0].value);
				}
				
				temp_data.append("\n\n");
			}
			total_sum = Integer.toString(sum) + ",00 €";
			

			//order data complete
			String order_data= temp_data.toString();
			temp_data.delete(0, temp_data.length());

			
			//get customer infos and validate them				
			//validate data and return with error message if necessary
			EmailValidator ev = EmailValidator.getInstance();
	 

			if ((customer_email.equals("")) || (!ev.isValid(customer_email)))
			{ 
					jsonResult.put("success", "false");
					jsonResult.put("error", "invalid email address");
					jsonResult.put("value", customer_email);
					 map.put("result", jsonResult.toJSONString());     
					 System.out.println(jsonResult.toJSONString()); return map;
			}
			

			if ((String) customer.get("name") != null)
			{  
				temp_data.append((String) customer.get("name"));
				temp_data.append("\n");
				
			}			
			else 
			{
				jsonResult.put("success", "false");
				jsonResult.put("error", "missing customer name");
				map.put("result", jsonResult.toJSONString());     
				System.out.println(jsonResult.toJSONString()); return map;
				
			}
			
			if ((String) customer.get("address") != null)
			{  
				temp_data.append((String) customer.get("address"));
				temp_data.append("\n");
				
			}			
			else 
			{
				jsonResult.put("success", "false");
				jsonResult.put("error", "missing address");
				map.put("result", jsonResult.toJSONString());     
				System.out.println(jsonResult.toJSONString()); return map;
			}
			
			if ((String) customer.get("zipcode") != null || (String) customer.get("city") != null)
			{   
				temp_data.append((String) customer.get("zipcode"));
				temp_data.append(" ");
				temp_data.append((String) customer.get("city"));
				temp_data.append("\n");
			 
			}	
			else
			{
				jsonResult.put("success", "false");
				jsonResult.put("error", "missing zipcode or city");
				map.put("result", jsonResult.toJSONString()); 
				System.out.println(jsonResult.toJSONString()); return map;
			}
			
			if ((String) customer.get("country") != null)
			{   
				temp_data.append((String) customer.get("country"));
				temp_data.append("\n");

			}
			else
			{
				jsonResult.put("success", "false");
				jsonResult.put("error", "missing customer address country");
				map.put("result", jsonResult.toJSONString()); 
				System.out.println(jsonResult.toJSONString()); return map; 
			}
			//customer info complete
			String customer_info = temp_data.toString();
			temp_data.delete(0, temp_data.length());
			
			//get delivery info and validate them if existent
			if ((JSONObject) jsonObject.get("delivery") != null)
			{
				JSONObject delivery = (JSONObject) jsonObject.get("delivery");

				if ((String) delivery.get("name") != null)
				{  
					temp_data.append((String) delivery.get("name"));
					temp_data.append("\n");
					
				}			
				else 
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "missing delivery address name");
					map.put("result", jsonResult.toJSONString());     
					System.out.println(jsonResult.toJSONString()); return map;
					
				}
				
				if ((String) delivery.get("address") != null)
				{  
					temp_data.append((String) delivery.get("address"));
					temp_data.append("\n");
					
				}			
				else 
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "missing delivery address");
					map.put("result", jsonResult.toJSONString());     
					System.out.println(jsonResult.toJSONString()); return map;
				}
				
				if ((String) delivery.get("zipcode") != null || (String) delivery.get("city") != null)
				{   
					temp_data.append((String) delivery.get("zipcode"));
					temp_data.append(" ");
					temp_data.append((String) delivery.get("city"));
					temp_data.append("\n");
				 
				}	
				else
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "missing delivery zipcode or city");
					map.put("result", jsonResult.toJSONString()); 
					System.out.println(jsonResult.toJSONString()); return map;
				}
				
				if ((String) delivery.get("country") != null)
				{   
					temp_data.append((String) delivery.get("country"));
					temp_data.append("\n");

				}
				else
				{
					jsonResult.put("success", "false");
					jsonResult.put("error", "missing delivery address country");
					map.put("result", jsonResult.toJSONString()); 
					System.out.println(jsonResult.toJSONString()); return map; 
				}
				//delivery info complete
				
			}
			//delivery info complete
			String delivery_info = temp_data.toString();
			temp_data.delete(0, temp_data.length());
			
			// try to send confirmation email to customer
			Email confirm_email = Email.getEmail(I18nUtil.getEmailFilename(context.getCurrentLocale(), "order_confirm"));
			confirm_email.addRecipient(customer_email);
			confirm_email.addArgument(new Date()); 
			confirm_email.addArgument(customer_email); 
			confirm_email.addArgument(customer_info);
			confirm_email.addArgument(delivery_info); 
			confirm_email.addArgument(order_data);
			confirm_email.addArgument(total_sum);

			System.out.println("Confirm email....");
			try {
				System.out.println("try to send...");
				confirm_email.send(); 
				 System.out.println("should be OK!");        
			} catch ( MessagingException me) {
				jsonResult.put("success", "false");
				jsonResult.put("error", "customer SMTPAddressFailedException");
				map.put("result", jsonResult.toJSONString());
				System.out.println(jsonResult.toJSONString()); return map;
			}
			

			// try to send email to order recipient
			Email email = Email.getEmail(I18nUtil.getEmailFilename(context.getCurrentLocale(), "order"));
			email.addRecipient(ConfigurationManager.getProperty("order.recipient"));

			email.addArgument(new Date()); 
			email.addArgument(customer_email); 
			email.addArgument(customer_info); 
			email.addArgument(delivery_info);
			email.addArgument(order_data);
			email.addArgument(total_sum);


			try {
				email.send();          
			} catch ( MessagingException me) {
				jsonResult.put("success", "false");
				jsonResult.put("error", "uvg SMTPAddressFailedException");
				map.put("result", jsonResult.toJSONString());
				System.out.println(jsonResult.toJSONString()); return map;
			}

			// everything ok and emails sent
			jsonResult.put("success", "true");
			map.put("result", jsonResult.toJSONString());
			System.out.println(jsonResult.toJSONString()); return map;
		} catch (ParseException pe){	
		//troubles with parameter parsing
		
			
			//Syntax error
			System.out.println("position: " + pe.getPosition());
			System.out.println(pe);
			jsonResult.put("success", "false");
			jsonResult.put("error", "position: " + pe.getPosition() + pe);
			map.put("result", jsonResult.toJSONString());	
			System.out.println(jsonResult.toJSONString()); return map;
			
		 } catch (NullPointerException npe){
			
			//missing some parameter
			jsonResult.put("success", "false");
			jsonResult.put("error", "Missing object (items, sum or customer)");
			map.put("result", jsonResult.toJSONString());	
			System.out.println(jsonResult.toJSONString()); return map;
			
		} 
		
	}

}

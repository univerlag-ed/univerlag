package org.dspace.app.xmlui.utils;

import org.apache.log4j.Logger;
import org.dspace.app.xmlui.aspect.artifactbrowser.OrderAction;

import java.text.DecimalFormat;
import java.util.Arrays;

/**
 * The Bill class holds informations of product ordering and
 * provides methods for price calculation.
 *
 * Created by Marianna Muehlhoelzer on 21.11.14.
 *
 */
public class Bill {

    //Countries of EUROPECODE {"Belgien", "Bulgarien", "Dänemark", "Estland", "Finnland", "Frankreich", "Griechenland", "Irland", "Italien", "Kroatien", "Lettland", "Litauen", "Luxemburg", "Malta", "Niederlande", "Österreich", "Polen", "Portugal", "Rumänien", "Schweden", "Slowakei", "Slowenien", "Spanien", "Tschechische Republik", "Ungarn", "Vereinigtes Königreich", "Zypern"};

   /* private static final String[] EUROPECODE = new String[]
            {"23","36", "50", "54", "57", "58", "69", "85", "89", "109", "114", "119", "120", "126", "148", "248", "167", "168", "173", "181", "190", "191", "195", "221", "230", "238", "244"};*/

    private static final String[] EUROPECODE = new String[]
            {"BE","BG", "DK", "EE", "FI", "FR", "GR", "IE", "IT", "HR", "LV", "LT", "LU", "MT", "NL", "AT", "PL", "PT", "RO", "SE", "SK", "SI", "ES", "CZ", "HU", "GB", "CY"};

    //special country codes:
    //Germany - 46; USA - 237

    //Weight- and price categories for shipping

    private static final Integer[] weightCatDE = new Integer[] {5000,10000,100000,300000,1000000000};
    private static final Integer[] amountCatDE = new Integer[] {250,350,450,750,100};

    private static final Integer[] weightCatEU = new Integer[] {5000,100000, 1000000000};
    private static final Integer[] amountCatEU = new Integer[] {450,650,100};

    private static final Integer[] weightCatUS = {2000,1000000000};
    private static final Integer[] amountCatUS = {1250,-100};

    //avarage weight of page of print publications in decigram
    private final int pageWeight = 26;

    //avarage weigth of cdroms and dvds in decigram
    private final int noprintWeight = 2000;

    //The weight of actual products in the shopping cart in cent
    private int weightSum;

    //The price of actual products in the shopping cart in cent
    private int amountSum;

    DecimalFormat df = new DecimalFormat("##0.00");

    /** log4j logger */
    private static Logger log = Logger.getLogger(OrderAction.class);

    public Bill(){
        init();
    }

    public void init(){
        this.weightSum = 0;
        this.amountSum = 0;
    }


    /**
     * Adds product weight to total weight
     *
     * @param count
     *            number of products
     * @param size
     *            if size > 0 product is print and size means number of pages
     *            els product is no print
     */
    public void addWeight(String count, String size)
    {
        int c = 0;
        int s = 0;

        try{
            c = Integer.parseInt(count);
            s = Integer.parseInt(size);
        }
        catch (NumberFormatException nfe){
            log.warn("Trying to add invalid weight to bill: " + count + " * " + size);
        }
        System.out.println("Bill quantity: " + c);
        System.out.println("Bill extent: " + s);
        System.out.println("weightSum before: " + weightSum);

        if (c > 0 ) {
            if (s > 0)
            {
                weightSum +=  (pageWeight * c * s);
            }
            else
            {
                weightSum += (noprintWeight * c);
            }
        }
        int temp =  pageWeight * c;
        System.out.println("pageWeight * c: " + temp);
        temp = temp * s;
        System.out.println("pageWeight * c * s: " + temp);
        int temp2 = weightSum;
        temp2 +=  (pageWeight * c * s);
        System.out.println("temp2 after: " + temp2 );
        System.out.println("weightSum after: " + weightSum );

    }

    /**
     * Adds product price to total price
     *
     * @param count
     *            number of products
     * @param price
     *            product price
     */
    public void addPrice(String count, String price)
    {
        int c = 0;
        int p = 0;

        try {
            c = Integer.parseInt(count);
            p = Integer.parseInt(price.replace(",", ""));


        }
        catch (NumberFormatException nfe) {
            log.warn("Trying to add invalid price to bill: " + count + " * " + price );
        }

        if (c > 0) {
            amountSum +=  (c * p );
        }
    }

    /**
     * Gives the cost of all ordered products
     * in euro
     *
     * @return
     *            cost of products
     */
    private int calcProductCost() {

        return amountSum;
    }

    /**
     * Gives the cost of all ordered products
     * with two decimal places in euro
     *
     * @return
     *            cost of products
     */
    public String getProductCost() {

        return df.format(amountSum/100.00);
    }

    /**
     * Gives the delivery cost of order
     * with two decimal places in euro
     * It depends on the country of destination.
     * Costs for countries out of Germany, US and
     * Europe can not be calculated.
     * i.e. cost= 0
     *
     * @param destination
     *          country code of destination
     * @return
     *              shipping cost 
     *              cost or
     *             -1 if country unknown or costs not calculable
     */
    private int calcShippingCost(String destination)
    {
        if (weightSum == 0){
            return 0;
        }
        else {
            Integer[] weightCat = {1000000000};
            Integer[] amountCat = {-100};

            int amount = 0;

            if (destination.equals("DE")) {
                weightCat = weightCatDE;
                amountCat = amountCatDE;
            } else if (Arrays.asList(EUROPECODE).contains(destination)) {
                weightCat = weightCatEU;
                amountCat = amountCatEU;
            } else if (destination.equals("US")) {
                weightCat = weightCatUS;
                amountCat = amountCatUS;
            }

            System.out.println("destination: " + destination);
            boolean found = false;
            int i = 0;

            System.out.println("Catalog length: " + weightCat.length);
            System.out.println("weightSum: " + weightSum);

            while (i < weightCat.length && !found) {
                System.out.println("Look up wheight table...");
                if (weightSum <= weightCat[i]) {
                    found = true;
                    amount = amountCat[i];
                    System.out.println("amount: " + amount);
                }
                i++;
            }

			if ((destination.equals("DE") && calcProductCost() > 6000) || (Arrays.asList(EUROPECODE).contains(destination) && calcProductCost() > 7000))
			{
				System.out.println("product costs with discount: " + calcProductCost());
				return 0;
			}
			else {
				System.out.println("product costs: " + calcProductCost());
				return amount;
			}
        }
    }

    /**
     * Gives getShippingCost result as String
     * with two decimal places in euro
     *
     * @param where
     *          country code of destination
     * @return
     *          delivery cost or 0.00
     */
    public String getShippingCost(String where)
    {

			int cost = calcShippingCost(where);
			System.out.println("cost string: " + df.format(cost/100.00));
			return df.format(cost/100.00);

    }

    /**
     * Gives total price of order
     * i.e. sum of product cost + shipping cost
     * with two decimal places in euro
     *
     * @param target
     *          destination country code
     * @return
     *          total price to pay for order
     */
    public String getTotalSum(String target) {

        if (calcShippingCost(target) > 0) {
            return df.format((calcShippingCost(target) + calcProductCost()) / 100.00);
        } else{
            return df.format(calcProductCost() / 100.00);
        }
    }

    public static void main(String[] args){

        Bill mybill = new Bill();

        String a = "3";
        String b = "230";
        mybill.addWeight(a, b);
        String c = mybill.getProductCost();
        String d = mybill.getShippingCost("US");


        System.out.println("Products: " + c);
        System.out.println("Shipping: " + d);

    }

}

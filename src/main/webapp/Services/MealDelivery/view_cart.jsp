<%@ page import="java.sql.*, java.text.DecimalFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Debug View Cart</title>
<style>
  body {font-family: Arial, sans-serif; margin: 40px;}
  table {width: 90%; border-collapse: collapse; margin-bottom: 20px;}
  th, td {border: 1px solid #ddd; padding: 10px; text-align: center;}
  th {background-color: #f2f2f2;}
  .debug {color: #444; font-size: 14px; margin-top: 10px;}
  .error {color: red;}
</style>
</head>
<body>



<%
String url  = "jdbc:mysql://localhost:3306/jad_assign1?useSSL=false&serverTimezone=UTC&characterEncoding=utf8";
String user = "root";
String pass = "1G9r5a6c1E**";

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;
DecimalFormat df = new DecimalFormat("#,##0.00");

double total = 0.0;
String appliedDiscount = "";
double discountAmount = 0.0;
double discountedTotal = 0.0;

try {
    
    Class.forName("com.mysql.cj.jdbc.Driver");

   
    conn = DriverManager.getConnection(url, user, pass);
   

    String sql =
        "SELECT m.meal_name, p.name AS provider_name, ci.quantity, ci.delivery_date, m.price " +
        "FROM cart_item ci " +
        "JOIN meal m ON ci.service_variant_id = m.id " +
        "JOIN meal_provider p ON ci.provider_id = p.id " +
        "WHERE ci.status = 'PENDING' " +
        "ORDER BY ci.delivery_date";

  
    ps = conn.prepareStatement(sql);
    rs = ps.executeQuery();

    boolean hasRows = false;
%>

<table>
  <tr>
    <th>Meal</th>
    <th>Provider</th>
    <th>Qty</th>
    <th>Delivery Date</th>
    <th>Subtotal</th>
  </tr>

<%
    while (rs.next()) {
        hasRows = true;
        String meal = rs.getString("meal_name");
        String provider = rs.getString("provider_name");
        int qty = rs.getInt("quantity");
        double price = rs.getDouble("price");
        String delivery = rs.getString("delivery_date");

        double subtotal = price * qty;
        total += subtotal;

        
%>
  <tr>
    <td><%= meal %></td>
    <td><%= provider %></td>
    <td><%= qty %></td>
    <td><%= delivery %></td>
    <td>$<%= df.format(subtotal) %></td>
  </tr>
<%
    }

    if (!hasRows) {
        out.println("<p class='debug'>[DEBUG] No items found in cart_item table (status='PENDING').</p>");
    }

    rs.close();
    ps.close();

    PreparedStatement ps2 = conn.prepareStatement(
        "SELECT name, discount_type, value, min_spend FROM meal_discount WHERE is_active=1"
    );
    ResultSet rs2 = ps2.executeQuery();

    while (rs2.next()) {
        double minSpend = rs2.getDouble("min_spend");
        String type = rs2.getString("discount_type");
        double value = rs2.getDouble("value");

     
        if (total >= minSpend) {
            appliedDiscount = rs2.getString("name");
            if ("PERCENT_OFF".equals(type)) {
                discountAmount = total * (value / 100);
            } else if ("FLAT_OFF".equals(type)) {
                discountAmount = value;
            } else if ("FREE_DELIVERY".equals(type)) {
                discountAmount = 5.00;
            }
        }
    }

    discountedTotal = total - discountAmount;

    rs2.close();
    ps2.close();

} catch (Exception e) {
    out.println("<p class='error'>Error: " + e.getMessage() + "</p>");
    e.printStackTrace();
} finally {
    if (rs != null) rs.close();
    if (ps != null) ps.close();
    if (conn != null) conn.close();
}
%>

</table>

<%
if (!appliedDiscount.isEmpty()) {
%>
<p style="color:green;">Discount Applied: <%= appliedDiscount %> (You saved $<%= df.format(discountAmount) %>)</p>
<p class="total">Total After Discount: $<%= df.format(discountedTotal) %></p>
<%
} else {
%>
<p class="total">Total: $<%= df.format(total) %></p>
<p style="color:gray;">No discounts applied yet.</p>
<%
}
%>

</body>
</html>

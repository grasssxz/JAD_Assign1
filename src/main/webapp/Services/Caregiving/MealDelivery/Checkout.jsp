<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Checkout</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 p-10">
<%
    Integer memberId = (Integer) session.getAttribute("member_id");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    // ===== GET USER CART =====
    PreparedStatement psCart = conn.prepareStatement(
        "SELECT id FROM cart WHERE member_id=?"
    );
    psCart.setInt(1, memberId);
    ResultSet rsCart = psCart.executeQuery();

    int cartId = -1;
    if (rsCart.next()) cartId = rsCart.getInt("id");

    if (cartId == -1) {
%>
        <p>No cart found.</p>
<%
        return;
    }

    // ===== GET PENDING CART ITEMS =====
    PreparedStatement psItems = conn.prepareStatement(
        "SELECT ci.*, m.meal_name, m.price " +
        "FROM cart_item ci " +
        "JOIN meal m ON ci.service_variant_id = m.id " +
        "WHERE ci.cart_id=? AND ci.status='pending'"
    );
    psItems.setInt(1, cartId);
    ResultSet rsItems = psItems.executeQuery();

    double subtotal = 0;
%>

<div class="max-w-4xl mx-auto bg-white p-6 rounded shadow">

    <h1 class="text-3xl font-bold mb-6">Checkout</h1>

    <table class="w-full border-collapse mb-6">
        <tr class="border-b font-semibold">
            <td class="p-2">Meal</td>
            <td class="p-2 text-center">Qty</td>
            <td class="p-2 text-right">Price</td>
            <td class="p-2 text-right">Total</td>
        </tr>

        <%
            while (rsItems.next()) {
                String name = rsItems.getString("meal_name");
                double price = rsItems.getDouble("price");
                int qty = rsItems.getInt("quantity");

                double rowTotal = price * qty;
                subtotal += rowTotal;
        %>

        <tr class="border-b">
            <td class="p-2"><%= name %></td>
            <td class="p-2 text-center"><%= qty %></td>
            <td class="p-2 text-right">$<%= price %></td>
            <td class="p-2 text-right">$<%= String.format("%.2f", rowTotal) %></td>
        </tr>

        <% } %>
    </table>

<%
    // ===== DISCOUNT PROCESSING =====
    PreparedStatement psDisc = conn.prepareStatement("SELECT * FROM meal_discount");
    ResultSet rsDisc = psDisc.executeQuery();

    double bestDiscount = 0;
    String discountName = "";

    while (rsDisc.next()) {
        double minSpend = rsDisc.getDouble("min_spend");
        String type = rsDisc.getString("discount_type");
        double value = rsDisc.getDouble("value");
        String name = rsDisc.getString("name");

        if (subtotal >= minSpend) {
            double calculated = 0;

            if (type.equals("PERCENT_OFF"))
                calculated = subtotal * (value / 100);
            else
                calculated = value;

            if (calculated > bestDiscount) {
                bestDiscount = calculated;
                discountName = name;
            }
        }
    }

    double finalTotal = subtotal - bestDiscount;
    if (finalTotal < 0) finalTotal = 0;

%>

    <div class="text-right text-lg font-medium">
        Subtotal: $<%= String.format("%.2f", subtotal) %><br>
        Discount: <%= discountName.equals("") ? "None" : discountName %> 
        <% if (!discountName.equals("")) { %>
           (-$<%= String.format("%.2f", bestDiscount) %>)
        <% } %>
        <br><br>
        <span class="text-2xl font-bold">Total: $<%= String.format("%.2f", finalTotal) %></span>
    </div>

    <form action="ConfirmCheckout.jsp" method="post" class="text-right mt-6">
        <input type="hidden" name="cart_id" value="<%= cartId %>">

        <button class="bg-green-600 text-white px-5 py-3 rounded hover:bg-green-700">
            Confirm Checkout
        </button>
    </form>

</div>

</body>
</html>

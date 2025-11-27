<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>My Cart – Meal Delivery</title>
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
    "SELECT id FROM cart WHERE member_id=? ORDER BY id DESC LIMIT 1"
);

    psCart.setInt(1, memberId);
    ResultSet rsCart = psCart.executeQuery();

    int cartId = -1;
    if (rsCart.next()) cartId = rsCart.getInt("id");
%>

<div class="max-w-5xl mx-auto">

    <h1 class="text-3xl font-bold mb-8">My Cart</h1>

    <%
        if (cartId == -1) {
    %>
        <p class="text-gray-600">Your cart is empty.</p>
    <%
        conn.close();
        return;
    }

    // ===== GET CART ITEMS =====
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

    <div class="bg-white p-6 rounded-lg shadow">

        <table class="w-full border-collapse">
            <tr class="border-b font-semibold">
                <td class="p-3">Meal</td>
                <td class="p-3 text-center">Qty</td>
                <td class="p-3 text-right">Price</td>
                <td class="p-3 text-right">Total</td>
                <td class="p-3 text-center">Action</td>
            </tr>

            <%
                while (rsItems.next()) {
                    int itemId = rsItems.getInt("id");
                    String mealName = rsItems.getString("meal_name");
                    double price = rsItems.getDouble("price");
                    int qty = rsItems.getInt("quantity");

                    double rowTotal = price * qty;
                    subtotal += rowTotal;
            %>

            <tr class="border-b">
                <td class="p-3"><%= mealName %></td>

                <td class="p-3 text-center">
                    <form action="UpdateCart.jsp" method="post" class="inline">
                        <input type="hidden" name="item_id" value="<%= itemId %>">
                        <input type="number" name="quantity" value="<%= qty %>"
                               min="1"
                               class="w-16 border rounded p-1 text-center" />
                        <button class="text-blue-600 hover:underline ml-2">Update</button>
                    </form>
                </td>

                <td class="p-3 text-right">$<%= String.format("%.2f", price) %></td>
                <td class="p-3 text-right">$<%= String.format("%.2f", rowTotal) %></td>

                <td class="p-3 text-center">
                    <form action="DeleteCartItem.jsp" method="post">
                        <input type="hidden" name="item_id" value="<%= itemId %>">
                        <button class="text-red-600 hover:underline">Delete</button>
                    </form>
                </td>
            </tr>

            <% } %>
        </table>

        <!-- SUBTOTAL -->
        <div class="text-right mt-6 text-lg font-semibold">
            Subtotal: $<%= String.format("%.2f", subtotal) %>
        </div>

        <%
            // ==== DISCOUNTS ====
            PreparedStatement psDisc = conn.prepareStatement(
                "SELECT * FROM meal_discount"
            );
            ResultSet rsDisc = psDisc.executeQuery();

            double bestDiscount = 0;
            String bestName = "";

            while (rsDisc.next()) {
                double minSpend = rsDisc.getDouble("min_spend");
                double value = rsDisc.getDouble("value");
                String type = rsDisc.getString("discount_type");
                String name = rsDisc.getString("name");

                if (subtotal >= minSpend) {
                    double computed = 0;

                    if (type.equals("PERCENT_OFF"))
                        computed = subtotal * (value / 100);
                    else
                        computed = value;

                    if (computed > bestDiscount) {
                        bestDiscount = computed;
                        bestName = name;
                    }
                }
            }

            double finalTotal = subtotal - bestDiscount;
            if (finalTotal < 0) finalTotal = 0;
        %>

        <!-- DISCOUNT -->
        <div class="text-right mt-2 text-green-600">
            Best Discount: <%= bestName.equals("") ? "None" : bestName %>
            <% if (!bestName.equals("")) { %>
                <br>Saved: -$<%= String.format("%.2f", bestDiscount) %>
            <% } %>
        </div>

        <!-- FINAL TOTAL -->
        <div class="text-right mt-4 text-2xl font-bold">
            Total: $<%= String.format("%.2f", finalTotal) %>
        </div>

    </div>
    <!-- CHECKOUT BUTTON -->
<div class="text-right mt-6">
    <a href="Checkout.jsp"
       class="inline-block bg-green-600 text-white px-6 py-3 rounded-lg hover:bg-green-700">
        Proceed to Checkout
    </a>
</div>
    

</div>

</body>
</html>

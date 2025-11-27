<%@ page import="java.sql.*, java.util.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />

<%
    int cartId = Integer.parseInt(request.getParameter("cart_id"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    // ITEM DATA HOLDER
    class CartItemData {
        int mealId, quantity, stock;
        String mealName;
    }

    ArrayList<CartItemData> items = new ArrayList<>();

    // 1. LOAD ALL ITEMS INTO MEMORY (NO SCROLLING NEEDED)
    PreparedStatement psItems = conn.prepareStatement(
        "SELECT ci.quantity, m.id AS meal_id, m.stock, m.meal_name " +
        "FROM cart_item ci " +
        "JOIN meal m ON ci.service_variant_id = m.service_variant_id " +
        "WHERE ci.cart_id=? AND ci.status='PENDING'"
    );
    psItems.setInt(1, cartId);
    ResultSet rsItems = psItems.executeQuery();

    boolean stockError = false;
    String stockMealName = "";

    while (rsItems.next()) {
        CartItemData data = new CartItemData();
        data.mealId   = rsItems.getInt("meal_id");
        data.quantity = rsItems.getInt("quantity");
        data.stock    = rsItems.getInt("stock");
        data.mealName = rsItems.getString("meal_name");

        // Save item
        items.add(data);

        // Stock check
        if (data.quantity > data.stock) {
            stockError = true;
            stockMealName = data.mealName;
        }
    }

    if (stockError) {
%>
        <script>
        alert("Checkout failed:\nNot enough stock for: <%= stockMealName %>");
        window.location.href = "ViewCart.jsp";
        </script>
<%
        conn.close();
        return;
    }

    // 2. DEDUCT STOCK (USING SAVED LIST ITEMS)
    for (CartItemData item : items) {

        PreparedStatement psDeduct = conn.prepareStatement(
            "UPDATE meal SET stock = stock - ? WHERE id=?"
        );
        psDeduct.setInt(1, item.quantity);
        psDeduct.setInt(2, item.mealId);
        psDeduct.executeUpdate();
    }

    // 3. MARK ITEMS AS COMPLETED
    PreparedStatement psUpdate = conn.prepareStatement(
        "UPDATE cart_item SET status='COMPLETED' WHERE cart_id=? AND status='PENDING'"
    );
    psUpdate.setInt(1, cartId);
    psUpdate.executeUpdate();

    conn.close();
%>

<script>
alert("Checkout successful! Stock deducted and items marked as completed.");
window.location.href = "ViewCart.jsp";
</script>

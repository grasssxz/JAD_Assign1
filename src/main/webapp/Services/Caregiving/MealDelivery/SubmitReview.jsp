<%@ page import="java.sql.*" %>

<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<%
    request.setCharacterEncoding("UTF-8");

    Integer memberId = (Integer) session.getAttribute("member_id");
    if (memberId == null) {
%>
        <script>
            alert("Please log in first.");
            window.location.href = "../../login/login.html";
        </script>
<%
        return;
    }

    int providerId   = Integer.parseInt(request.getParameter("provider_id"));
    int cartItemId   = Integer.parseInt(request.getParameter("cart_item_id"));
    int rating       = Integer.parseInt(request.getParameter("rating"));
    String review    = request.getParameter("review_text");

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    // 1. GET meal_id from cart_item
    PreparedStatement psMeal = conn.prepareStatement(
        "SELECT m.id AS meal_id " +
        "FROM cart_item ci JOIN meal m ON ci.service_variant_id = m.service_variant_id " +
        "WHERE ci.id=? AND ci.provider_id=?"
    );
    psMeal.setInt(1, cartItemId);
    psMeal.setInt(2, providerId);

    ResultSet rsMeal = psMeal.executeQuery();

    int mealId = -1;
    if (rsMeal.next()) {
        mealId = rsMeal.getInt("meal_id");
    } else {
%>
        <script>
            alert("Error: Unable to find meal for this cart item.");
            history.back();
        </script>
<%
        conn.close();
        return;
    }

    // 2. ENSURE USER OWNS THIS CART ITEM
    PreparedStatement psCheckOwner = conn.prepareStatement(
        "SELECT ci.id FROM cart_item ci " +
        "JOIN cart c ON ci.cart_id = c.id " +
        "WHERE ci.id=? AND c.member_id=? AND ci.status='COMPLETED'"
    );
    psCheckOwner.setInt(1, cartItemId);
    psCheckOwner.setInt(2, memberId);

    ResultSet rsCheckOwner = psCheckOwner.executeQuery();
    if (!rsCheckOwner.next()) {
%>
        <script>
            alert("Invalid access. You can only review completed orders that you purchased.");
            window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
        </script>
<%
        conn.close();
        return;
    }

    // 3. INSERT REVIEW
    PreparedStatement psInsert = conn.prepareStatement(
        "INSERT INTO reviews (member_id, meal_id, cart_item_id, rating, review_text, created_at) " +
        "VALUES (?, ?, ?, ?, ?, NOW())"
    );
    psInsert.setInt(1, memberId);
    psInsert.setInt(2, mealId);
    psInsert.setInt(3, cartItemId);
    psInsert.setInt(4, rating);
    psInsert.setString(5, review);

    psInsert.executeUpdate();
    conn.close();
%>

<script>
alert("Review submitted successfully!");
window.location.href = "MealProviderDetails.jsp?id=<%= providerId %>";
</script>

<%@ page import="java.sql.*" %>

<!-- LOGIN REQUIRED -->
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

    // ======== GET FORM DATA ========
    int providerId   = Integer.parseInt(request.getParameter("provider_id"));
    int mealId       = Integer.parseInt(request.getParameter("meal_id"));
    double price     = Double.parseDouble(request.getParameter("price"));

    String mealOption   = request.getParameter("meal_option");
    String deliveryDate = request.getParameter("delivery_date");
    int quantity        = Integer.parseInt(request.getParameter("quantity"));

    // ======== CONNECT DB ========
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    // ======== GET OR CREATE CART ========
    int cartId = -1;

    PreparedStatement psCheck = conn.prepareStatement(
        "SELECT id FROM cart WHERE member_id=?"
    );
    psCheck.setInt(1, memberId);
    ResultSet rsCheck = psCheck.executeQuery();

    if (rsCheck.next()) {
        cartId = rsCheck.getInt("id");
    } else {
        PreparedStatement psCreate = conn.prepareStatement(
            "INSERT INTO cart (member_id, created_at) VALUES (?, NOW())",
            Statement.RETURN_GENERATED_KEYS
        );
        psCreate.setInt(1, memberId);
        psCreate.executeUpdate();
        ResultSet rsNew = psCreate.getGeneratedKeys();
        if (rsNew.next()) cartId = rsNew.getInt(1);
    }

    if (cartId <= 0) {
        out.print("ERROR: Failed to create cart");
        return;
    }

    // ======== GET service_variant_id FROM MEAL TABLE ========
    PreparedStatement psMeal = conn.prepareStatement(
        "SELECT service_variant_id, stock FROM meal WHERE id=?"
    );
    psMeal.setInt(1, mealId);
    ResultSet rsMeal = psMeal.executeQuery();

    int serviceVariantId = -1;
    int stock = 0;

    if (rsMeal.next()) {
        serviceVariantId = rsMeal.getInt("service_variant_id");
        stock = rsMeal.getInt("stock");
    }

    if (serviceVariantId <= 0) {
        out.print("ERROR: Invalid meal or service variant");
        conn.close();
        return;
    }

    // ======== STOCK CHECK ========
    if (quantity > stock) {
%>
        <script>
            alert("Not enough stock available!");
            history.back();
        </script>
<%
        conn.close();
        return;
    }

    // ======== INSERT CART ITEM (CORRECT COLUMNS ONLY) ========
    PreparedStatement psItem = conn.prepareStatement(
        "INSERT INTO cart_item " +
        "(cart_id, service_variant_id, provider_id, quantity, meal_option, delivery_date, status) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?)"
    );

    psItem.setInt(1, cartId);
    psItem.setInt(2, serviceVariantId);
    psItem.setInt(3, providerId);
    psItem.setInt(4, quantity);
    psItem.setString(5, mealOption);
    psItem.setString(6, deliveryDate);
    psItem.setString(7, "PENDING");

    psItem.executeUpdate();

    conn.close();
%>

<script>
    alert("Added to cart successfully!");
    window.location.href = "ViewCart.jsp";
</script>

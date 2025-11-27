<jsp:include page="/auth/AuthCheck.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />

<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.*" %>

<%
    //  Guests cannot book
    //String type = (String) session.getAttribute("type");
    //if ("guest".equals(type)) {
    //    response.sendRedirect(request.getContextPath() + "/login/login.html");
    //    return;
    //}

    // SAFE NOW — authenticated user only
    Integer memberId = (Integer) session.getAttribute("member_id");





/* ================================
   READ FORM INPUTS (SAFE)
================================ */
int companyId = Integer.parseInt(request.getParameter("company_id"));

/* Fix: Handle missing order_total */
String totalStr = request.getParameter("order_total");
if (totalStr == null || totalStr.trim().isEmpty()) {
    totalStr = "0";
}
double clientSubmittedTotal = Double.parseDouble(totalStr);

/* Fix: Handle missing shipping fee */
String shippingStr = request.getParameter("shipping_fee");
if (shippingStr == null || shippingStr.trim().isEmpty()) {
    shippingStr = "0";
}
double shippingFeeSent = Double.parseDouble(shippingStr);

/* NEW: Booking Date */
/* NEW: Booking Date */
String bookingDateStr = request.getParameter("booking_date");
LocalDate bookingDate = LocalDate.parse(bookingDateStr);

/* ================================
   DB CONNECTION
================================ */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

// Begin transaction
conn.setAutoCommit(false);

/* ================================
   CHECK FOR CLASHING BOOKINGS
================================ */
PreparedStatement clashStmt = conn.prepareStatement(
    "SELECT COUNT(*) AS cnt FROM grocery_order " +
    "WHERE member_id = ? AND booking_date = ? AND status != 'CANCELLED'"
);
clashStmt.setInt(1, memberId);
clashStmt.setDate(2, java.sql.Date.valueOf(bookingDate));

ResultSet clashRs = clashStmt.executeQuery();
clashRs.next();
int clashCount = clashRs.getInt("cnt");

if (clashCount > 0) {
%>
<script>
    alert("You already have a grocery appointment on this date. Please choose another date.");
    window.history.back();
</script>
<%
    conn.rollback();
    return;
}


/* ================================
   DB CONNECTION
================================ */
Class.forName("com.mysql.cj.jdbc.Driver");
Connection con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**&serverTimezone=UTC"
);

// Begin transaction
conn.setAutoCommit(false);

try {

    /* ================================
       FETCH COMPANY INFO (delivery time)
    ================================ */
    PreparedStatement compStmt = conn.prepareStatement(
        "SELECT est_delivery_time FROM grocery_company WHERE id = ?"
    );
    compStmt.setInt(1, companyId);
    ResultSet compRs = compStmt.executeQuery();
    compRs.next();

    String deliveryTimeText = compRs.getString("est_delivery_time");

    /* Parse delivery time */
    int estMinutes = 45;
    try {
        String cleaned = deliveryTimeText.replace("mins", "")
                                         .replace("min", "")
                                         .replace(" ", "");
        String[] parts = cleaned.split("–|-");
        int minVal = Integer.parseInt(parts[0]);
        int maxVal = Integer.parseInt(parts[1]);
        estMinutes = (minVal + maxVal) / 2;
    } catch (Exception e) { estMinutes = 45; }

    LocalDateTime estimatedDelivery = bookingDate.atStartOfDay().plusMinutes(estMinutes);

    /* ================================
       FETCH DISCOUNT RULES
    ================================ */
    PreparedStatement discStmt = conn.prepareStatement(
        "SELECT d.* FROM grocery_company_discount cd " +
        "JOIN grocery_discount_rule d ON cd.rule_id = d.id " +
        "WHERE cd.company_id = ? AND d.is_active = 1"
    );
    discStmt.setInt(1, companyId);
    ResultSet discRs = discStmt.executeQuery();

    class Discount { int id; String type; double amount; double minOrder; boolean stack; }
    ArrayList<Discount> rules = new ArrayList<>();

    while (discRs.next()) {
        Discount d = new Discount();
        d.id = discRs.getInt("id");
        d.type = discRs.getString("type");
        d.amount = discRs.getDouble("amount");
        d.minOrder = discRs.getDouble("min_order_amount");
        d.stack = discRs.getInt("is_stackable") == 1;
        rules.add(d);
    }

    /* ================================
       REBUILD ORDER ITEMS
    ================================ */
    Enumeration<String> params = request.getParameterNames();
    HashMap<Integer, Integer> orderItems = new HashMap<>();

    while (params.hasMoreElements()) {
        String p = params.nextElement();
        if (p.startsWith("item_")) {
            int itemId = Integer.parseInt(p.substring(5));
            int qty = Integer.parseInt(request.getParameter(p));
            if (qty > 0) orderItems.put(itemId, qty);
        }
    }

    if (orderItems.size() == 0) {
%>
<script>
    alert("You must select at least 1 item.");
    window.history.back();
</script>
<%
        conn.rollback();
        return;
    }

    /* ================================
       STOCK VALIDATION + SUBTOTAL
    ================================ */
    double subtotal = 0;
    PreparedStatement stockStmt = conn.prepareStatement(
        "SELECT name, price, stock_quantity FROM grocery_item WHERE id = ? AND company_id = ? FOR UPDATE"
    );

    for (int itemId : orderItems.keySet()) {
        int qty = orderItems.get(itemId);

        stockStmt.setInt(1, itemId);
        stockStmt.setInt(2, companyId);
        ResultSet srs = stockStmt.executeQuery();

        if (!srs.next()) {
%>
<script>
    alert("Invalid item submitted.");
    window.history.back();
</script>
<%
            conn.rollback();
            return;
        }

        int stock = srs.getInt("stock_quantity");
        double price = srs.getDouble("price");
        String itemName = srs.getString("name");

        if (qty > stock) {
%>
<script>
    alert("Only <%= stock %> units of '<%= itemName %>' are available.");
    window.history.back();
</script>
<%
            conn.rollback();
            return;
        }

        subtotal += qty * price;
    }

    /* ================================
       APPLY DISCOUNTS
    ================================ */
    double discountAmount = 0;
    double shippingDiscount = 0;
    double bestNonStack = 0;
    double stackSum = 0;

    for (Discount d : rules) {
        if (subtotal >= d.minOrder) {

            if ("PERCENT".equalsIgnoreCase(d.type)) {
                double val = subtotal * (d.amount / 100);
                if (d.stack) stackSum += val; else bestNonStack = Math.max(bestNonStack, val);

            } else if ("FLAT".equalsIgnoreCase(d.type)) {
                double val = d.amount;
                if (d.stack) stackSum += val; else bestNonStack = Math.max(bestNonStack, val);

            } else if ("SHIPPING".equalsIgnoreCase(d.type)) {
                shippingDiscount = Math.max(shippingDiscount, d.amount);
            }
        }
    }

    discountAmount = stackSum + bestNonStack;

    double finalShipping = Math.max(0, shippingFeeSent - shippingDiscount);
    double finalTotal = subtotal + finalShipping - discountAmount;
    if (finalTotal < 0) finalTotal = 0;

    /* ================================
       INSERT ORDER (mark as COMPLETED immediately)
    ================================ */
    PreparedStatement insertOrder = conn.prepareStatement(
        "INSERT INTO grocery_order (member_id, company_id, total_price, status, booking_date, estimated_delivery) " +
        "VALUES (?,?,?,?,?,?)",
        Statement.RETURN_GENERATED_KEYS
    );

    insertOrder.setInt(1, memberId);
    insertOrder.setInt(2, companyId);
    insertOrder.setDouble(3, finalTotal);
    insertOrder.setString(4, "COMPLETED");
    insertOrder.setDate(5, java.sql.Date.valueOf(bookingDate));
    insertOrder.setTimestamp(6, java.sql.Timestamp.valueOf(estimatedDelivery));
    insertOrder.executeUpdate();

    ResultSet keyRs = insertOrder.getGeneratedKeys();
    keyRs.next();
    int orderId = keyRs.getInt(1);

    /* ================================
       INSERT ORDER ITEMS + DEDUCT STOCK
    ================================ */
    PreparedStatement insertItem = conn.prepareStatement(
        "INSERT INTO grocery_order_item (order_id, item_id, quantity, price_each) VALUES (?,?,?,?)"
    );
    PreparedStatement updateStock = conn.prepareStatement(
        "UPDATE grocery_item SET stock_quantity = stock_quantity - ? WHERE id = ?"
    );

    for (int itemId : orderItems.keySet()) {
        int qty = orderItems.get(itemId);

        PreparedStatement priceStmt = conn.prepareStatement(
            "SELECT price FROM grocery_item WHERE id=?"
        );
        priceStmt.setInt(1, itemId);
        ResultSet prs = priceStmt.executeQuery();
        prs.next();
        double price = prs.getDouble("price");

        insertItem.setInt(1, orderId);
        insertItem.setInt(2, itemId);
        insertItem.setInt(3, qty);
        insertItem.setDouble(4, price);
        insertItem.executeUpdate();

        updateStock.setInt(1, qty);
        updateStock.setInt(2, itemId);
        updateStock.executeUpdate();
    }

    conn.commit();
%>

<!-- SUCCESS PAGE -->
<link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">

<div class="max-w-lg mx-auto mt-20 p-10 bg-white shadow-lg rounded-xl text-center">
    <h1 class="text-3xl font-bold text-green-600 mb-4">Order Placed Successfully!</h1>

    <div class="text-left mt-6 bg-gray-50 p-6 rounded-lg border">
        <p><strong>Order ID:</strong> <%= orderId %></p>
        <p><strong>Booking Date:</strong> <%= bookingDate %></p>
        <p><strong>Est. Delivery:</strong> <%= estimatedDelivery %></p>
        <p><strong>Final Total:</strong> $<%= String.format("%.2f", finalTotal) %></p>
    </div>

    <!-- Return to Grocery Provider -->
    <a href="../Grocery/GroceryList.jsp"
       class="inline-block mt-6 px-6 py-3 bg-blue-600 text-white rounded-lg">
       Return to Grocery Providers
    </a>

    <!-- NEW: View My Appointments Button -->
    <a href="../Grocery/GroceryViewAppointments.jsp"
       class="inline-block mt-4 px-6 py-3 bg-green-600 text-white rounded-lg">
       View My Appointments
    </a>
</div>

<%
} catch (Exception e) {
    conn.rollback();
%>

<div class="p-10 max-w-xl mx-auto mt-10 bg-red-100 border border-red-300 text-red-700 rounded-lg">
    <h2 class="text-xl font-bold mb-3">Order Failed</h2>
    <p><%= e.getMessage() %></p>
</div>

<%
} finally {
    conn.setAutoCommit(true);
    conn.close();
}
%>

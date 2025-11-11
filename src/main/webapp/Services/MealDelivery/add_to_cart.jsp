<%@ page import="java.sql.*, java.time.*, java.time.temporal.ChronoUnit, java.io.*" %>
<%
    // ---------------------------
    // Database credentials
    // ---------------------------
    String url  = "jdbc:mysql://localhost:3306/jad_assign1?useSSL=false&serverTimezone=UTC&characterEncoding=utf8";
    String user = "root";
    String pass = "1G9r5a6c1E**";

    // ---------------------------
    // Request parameters from form (MealDelivery.html)
    // ---------------------------
    String memberIdStr  = request.getParameter("member_id");
    String mealName     = request.getParameter("meal_name");     // e.g. "Standard Lunch"
    String providerIdStr= request.getParameter("provider_id");   // e.g. 1
    String qtyStr       = request.getParameter("quantity");
    String deliveryDate = request.getParameter("delivery_date"); // YYYY-MM-DD
    String monthsStr    = request.getParameter("months");

    // ---------------------------
    // Basic validation
    // ---------------------------
    if (mealName == null || mealName.trim().isEmpty()) {
        out.println("<p style='color:red;'>Error: Meal name is required.</p>");
        return;
    }
    if (deliveryDate == null || deliveryDate.isEmpty()) {
        out.println("<p style='color:red;'>Error: Delivery date is required.</p>");
        return;
    }

    // Check date is within 90 days
    LocalDate selectedDate = LocalDate.parse(deliveryDate);
    LocalDate today = LocalDate.now();
    long daysBetween = ChronoUnit.DAYS.between(today, selectedDate);
    if (daysBetween < 0 || daysBetween > 90) {
        out.println("<p style='color:red;'>Error: Delivery date must be within 90 days from today.</p>");
        return;
    }

    // Convert numeric parameters safely
    int memberId = Integer.parseInt(memberIdStr);
    int providerId = Integer.parseInt(providerIdStr);
    int quantity = Integer.parseInt(qtyStr);
    int months = (monthsStr != null && !monthsStr.isEmpty()) ? Integer.parseInt(monthsStr) : 1;

    // ---------------------------
    // DB connection + logic
    // ---------------------------
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, pass);

        // 1. Check if member already has a cart
        int cartId = 0;
        ps = conn.prepareStatement("SELECT id FROM cart WHERE member_id = ?");
        ps.setInt(1, memberId);
        rs = ps.executeQuery();
        if (rs.next()) {
            cartId = rs.getInt("id");
        } else {
            // Create a new cart
            ps = conn.prepareStatement("INSERT INTO cart (member_id) VALUES (?)", Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, memberId);
            ps.executeUpdate();
            ResultSet genKeys = ps.getGeneratedKeys();
            if (genKeys.next()) cartId = genKeys.getInt(1);
            genKeys.close();
        }

        // 2. Lookup correct meal.id based on meal_name
        ps = conn.prepareStatement("SELECT id FROM meal WHERE meal_name = ?");
        ps.setString(1, mealName);
        rs = ps.executeQuery();
        int mealId = 0;
        if (rs.next()) {
            mealId = rs.getInt("id");
        } else {
            out.println("<p style='color:red;'>Error: Invalid meal selected. Please try again.</p>");
            return;
        }

        // 3. Insert into cart_item
        ps = conn.prepareStatement(
            "INSERT INTO cart_item (cart_id, service_variant_id, provider_id, quantity, delivery_date, months, status) " +
            "VALUES (?, ?, ?, ?, ?, ?, 'PENDING')"
        );
        ps.setInt(1, cartId);
        ps.setInt(2, mealId);
        ps.setInt(3, providerId);
        ps.setInt(4, quantity);
        ps.setString(5, deliveryDate);
        ps.setInt(6, months);

        int rows = ps.executeUpdate();
        if (rows > 0) {
            out.println("<p style='color:green;'>Meal added to cart successfully.</p>");
        } else {
            out.println("<p style='color:red;'>Failed to add meal to cart.</p>");
        }

    } catch (Exception e) {
        // Use StringWriter to print full error safely
        StringWriter sw = new StringWriter();
        e.printStackTrace(new PrintWriter(sw));
        out.println("<pre style='color:red;'>Error: " + sw.toString() + "</pre>");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (ps != null) try { ps.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>

<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Meal Delivery</title>
  <style>
    body {font-family: Arial, sans-serif; background: #fafafa; margin: 0; padding: 0;}
    .container {display: flex; padding: 30px;}
    .sidebar {width: 25%; background: #f0eaea; padding: 20px; border-radius: 10px; margin-right: 20px;}
    .content {flex: 1; background: #fff; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);}
    .meal-card {border-bottom: 1px solid #ddd; padding: 15px 0;}
    .meal-card h3 {margin: 0; color: #333;}
    .meal-card p {margin: 3px 0; color: #666;}
    button {background: #6a8f68; color: white; border: none; padding: 8px 14px; border-radius: 5px; cursor: pointer;}
    button:hover {background: #557755;}
    .discounts {margin-top: 40px; padding: 15px; background: #f0f7f0; border-radius: 8px; border: 1px solid #c7e0c7;}
    .discounts h3 {margin-top: 0;}
  </style>
</head>
<body>

<div class="container">
  <!-- Sidebar Filters -->
  <div class="sidebar">
    <h3>Filter Meals</h3>
    <form method="get" action="MealDelivery.jsp">
      <%
      String url  = "jdbc:mysql://localhost:3306/jad_assign1?useSSL=false&serverTimezone=UTC&characterEncoding=utf8";
      String user = "root";
      String pass = "1G9r5a6c1E**";

      Connection conn = null;
      PreparedStatement psCat = null, psOpt = null;
      ResultSet rsCat = null, rsOpt = null;

      try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          conn = DriverManager.getConnection(url, user, pass);

          psCat = conn.prepareStatement("SELECT id, name FROM meal_filter_category WHERE is_active=1");
          rsCat = psCat.executeQuery();

          while (rsCat.next()) {
              int catId = rsCat.getInt("id");
              String catName = rsCat.getString("name");
      %>
        <h4><%= catName %></h4>
        <%
            psOpt = conn.prepareStatement("SELECT id, label, value FROM meal_filter_option WHERE category_id=? AND is_active=1");
            psOpt.setInt(1, catId);
            rsOpt = psOpt.executeQuery();
            while (rsOpt.next()) {
        %>
          <label>
            <input type="checkbox" name="filter" value="<%= rsOpt.getString("value") %>">
            <%= rsOpt.getString("label") %>
          </label><br>
        <%
            }
            rsOpt.close();
            psOpt.close();
          }
      } catch (Exception e) {
          out.println("<p style='color:red;'>" + e.getMessage() + "</p>");
      } finally {
          if (rsOpt != null) rsOpt.close();
          if (psOpt != null) psOpt.close();
          if (rsCat != null) rsCat.close();
          if (psCat != null) psCat.close();
          if (conn != null) conn.close();
      }
      %>
      <br><button type="submit">Apply Filters</button>
    </form>
  </div>

  <!-- Main Content -->
  <div class="content">
    <h2>Available Meal Services</h2>
    <hr>
    <%
    String[] filters = request.getParameterValues("filter");
    String filterClause = "";

    if (filters != null && filters.length > 0) {
        StringBuilder sb = new StringBuilder(" AND (");
        for (int i = 0; i < filters.length; i++) {
            if (i > 0) sb.append(" OR ");
            sb.append("m.meal_type='").append(filters[i]).append("'")
              .append(" OR m.meal_type LIKE '%").append(filters[i]).append("%'")
              .append(" OR p.name='").append(filters[i]).append("'");
        }
        sb.append(")");
        filterClause = sb.toString();
    }

    Connection c2 = null;
    PreparedStatement ps2 = null;
    ResultSet rs2 = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        c2 = DriverManager.getConnection(url, user, pass);
        String sql =
        "SELECT m.id, m.meal_name, m.meal_type, m.description, m.price, p.id AS provider_id, p.name AS provider, p.rating " +
        "FROM meal m JOIN meal_provider p ON m.provider_id=p.id " +
        "WHERE m.is_active=1 AND p.is_active=1 " + filterClause +
        " ORDER BY p.name ASC";
        ps2 = c2.prepareStatement(sql);
        rs2 = ps2.executeQuery();

        boolean hasMeals = false;
        while (rs2.next()) {
            hasMeals = true;
    %>
    <div class="meal-card">
      <h3><%= rs2.getString("meal_name") %> - $<%= rs2.getDouble("price") %></h3>
      <p><b>Type:</b> <%= rs2.getString("meal_type") %> | 
         <b>Provider:</b> <%= rs2.getString("provider") %> | 
         <b>Rating:</b> <%= rs2.getDouble("rating") %></p>
      <p><%= rs2.getString("description") %></p>
      <form action="add_to_cart.jsp" method="post">
        <input type="hidden" name="member_id" value="1">
        <input type="hidden" name="meal_name" value="<%= rs2.getString("meal_name") %>">
        <input type="hidden" name="provider_id" value="<%= rs2.getInt("provider_id") %>">
        Quantity: <input type="number" name="quantity" value="1" min="1" required>
        Delivery Date: <input type="date" name="delivery_date" required><br><br>
        <input type="hidden" name="months" value="1">
        <button type="submit">Add to Cart</button>
      </form>
    </div>
    <hr>
    <%
        }
        if (!hasMeals) {
            out.println("<p style='color:red;'>No meals found for the selected filters.</p>");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>" + e.getMessage() + "</p>");
    } finally {
        if (rs2 != null) rs2.close();
        if (ps2 != null) ps2.close();
        if (c2 != null) c2.close();
    }
    %>

    <!-- Discounts Section -->
    <div class="discounts">
      <h3>Available Discounts</h3>
      <ul>
      <%
      Connection c3 = null; PreparedStatement ps3 = null; ResultSet rs3 = null;
      try {
          Class.forName("com.mysql.cj.jdbc.Driver");
          c3 = DriverManager.getConnection(url, user, pass);
          ps3 = c3.prepareStatement("SELECT name, description FROM meal_discount WHERE is_active=1");
          rs3 = ps3.executeQuery();
          while (rs3.next()) {
      %>
        <li><b><%= rs3.getString("name") %>:</b> <%= rs3.getString("description") %></li>
      <%
          }
      } catch (Exception e) {
          out.println("<li style='color:red;'>" + e.getMessage() + "</li>");
      } finally {
          if (rs3 != null) rs3.close();
          if (ps3 != null) ps3.close();
          if (c3 != null) c3.close();
      }
      %>
      </ul>
    </div>
  </div>
</div>
</body>
</html>

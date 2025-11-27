<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.math.BigDecimal" %>

<!-- ===== AUTH CHECK (ADMIN ONLY) ===== -->
<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<%
/* ===============================
   DB Connection
================================*/
String connURL =
"jdbc:mysql://localhost:3306/jad_assign1"
+ "?user=root"
+ "&password=1G9r5a6c1E**"
+ "&serverTimezone=UTC"
+ "&useSSL=false"
+ "&allowPublicKeyRetrieval=true";

Class.forName("com.mysql.cj.jdbc.Driver");

String action = request.getParameter("action");
if (action == null) action = "";

// form state
String formId = "";
String formCompanyId = "";
String formName = "";
String formDesc = "";
String formPrice = "";
String formAvailable = "1";
String formStockQty = "0";

String errorMsg = null;

Connection conn = null;

try {
    conn = DriverManager.getConnection(connURL);

    /* ===============================
       DELETE ITEM
    ================================*/
    if ("delete".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            PreparedStatement psDel =
                conn.prepareStatement("DELETE FROM grocery_item WHERE id=?");
            psDel.setInt(1, Integer.parseInt(idStr));
            psDel.executeUpdate();
            psDel.close();
        }
        response.sendRedirect("editGroceryItem.jsp");
        return;
    }

    /* ===============================
       SAVE ITEM (INSERT/UPDATE)
    ================================*/
    if ("save".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {

        String idStr = request.getParameter("id");
        String companyIdStr = request.getParameter("company_id");
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String priceStr = request.getParameter("price");
        int isAvailable = ("1".equals(request.getParameter("is_available")) ? 1 : 0);
        String stockStr = request.getParameter("stock_quantity");

        BigDecimal price = BigDecimal.ZERO;
        try { price = new BigDecimal(priceStr); } catch(Exception e){}

        int stockQty = 0;
        try { stockQty = Integer.parseInt(stockStr); } catch(Exception e){}

        int companyId = 0;
        try { companyId = Integer.parseInt(companyIdStr); } catch(Exception e){}

        /* ---- company exists check ---- */
        boolean companyExists = false;
        PreparedStatement psCheck =
            conn.prepareStatement("SELECT id FROM grocery_company WHERE id=?");
        psCheck.setInt(1, companyId);
        ResultSet rsCheck = psCheck.executeQuery();
        if (rsCheck.next()) companyExists = true;
        rsCheck.close();
        psCheck.close();

        if (!companyExists) {
            errorMsg = "Invalid Company ID.";
            formId = idStr;
            formCompanyId = companyIdStr;
            formName = name;
            formDesc = description;
            formPrice = priceStr;
            formAvailable = String.valueOf(isAvailable);
            formStockQty = stockStr;

        } else {
            if (idStr == null || idStr.trim().isEmpty()) {
                // INSERT
                PreparedStatement psIns = conn.prepareStatement(
                    "INSERT INTO grocery_item (company_id, name, description, price, is_available, stock_quantity)"
                    + " VALUES (?, ?, ?, ?, ?, ?)"
                );
                psIns.setInt(1, companyId);
                psIns.setString(2, name);
                psIns.setString(3, description);
                psIns.setBigDecimal(4, price);
                psIns.setInt(5, isAvailable);
                psIns.setInt(6, stockQty);
                psIns.executeUpdate();
                psIns.close();

            } else {
                // UPDATE
                PreparedStatement psUpd = conn.prepareStatement(
                    "UPDATE grocery_item SET company_id=?, name=?, description=?, price=?, is_available=?, stock_quantity=?"
                    + " WHERE id=?"
                );
                psUpd.setInt(1, companyId);
                psUpd.setString(2, name);
                psUpd.setString(3, description);
                psUpd.setBigDecimal(4, price);
                psUpd.setInt(5, isAvailable);
                psUpd.setInt(6, stockQty);
                psUpd.setInt(7, Integer.parseInt(idStr));
                psUpd.executeUpdate();
                psUpd.close();
            }

            response.sendRedirect("editGroceryItem.jsp");
            return;
        }
    }

    /* ===============================
       LOAD ITEM FOR EDIT
    ================================*/
    if ("edit".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {

            PreparedStatement psOne = conn.prepareStatement(
                "SELECT * FROM grocery_item WHERE id=?"
            );
            psOne.setInt(1, Integer.parseInt(idStr));
            ResultSet r1 = psOne.executeQuery();

            if (r1.next()) {
                formId = r1.getString("id");
                formCompanyId = r1.getString("company_id");
                formName = r1.getString("name");
                formDesc = r1.getString("description");
                formPrice = r1.getBigDecimal("price").toString();
                formAvailable = r1.getInt("is_available") + "";
                formStockQty = r1.getInt("stock_quantity") + "";
            }
            r1.close();
            psOne.close();
        }
    }

} catch (Exception e) {
    errorMsg = "Error: " + e.getMessage();
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Grocery Items</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 min-h-screen p-6">

<h1 class="text-3xl font-bold text-gray-800 mb-6">Grocery Items Management</h1>

<a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp"
   class="text-sm text-gray-700 hover:text-indigo-600">
   ← Back to Admin Home
</a>

<!-- ERROR -->
<% if (errorMsg != null) { %>
<div class="bg-red-200 border border-red-500 text-red-700 px-4 py-2 rounded mt-4">
    <%= errorMsg %>
</div>
<% } %>

<!-- ================= FORM CARD ================= -->
<div class="bg-white p-6 shadow rounded-xl mt-6 max-w-3xl">

  <h2 class="text-xl font-semibold mb-4">
    <%= (formId.isEmpty() ? "Create New Item" : "Edit Item #" + formId) %>
  </h2>

  <form method="post" action="editGroceryItem.jsp?action=save" class="space-y-4">

    <input type="hidden" name="id" value="<%=formId%>" />

    <!-- COMPANY DROPDOWN -->
    <div>
      <label class="font-medium">Company</label>
      <select name="company_id" required
              class="w-full mt-1 p-2 border rounded-lg">
        <option value="">-- Select Company --</option>
        <%
        PreparedStatement psComp = conn.prepareStatement(
            "SELECT id, name FROM grocery_company ORDER BY name");
        ResultSet rc = psComp.executeQuery();
        while (rc.next()) {
            String cid = rc.getString("id");
            String cname = rc.getString("name");
        %>
          <option value="<%=cid%>" <%= cid.equals(formCompanyId) ? "selected" : "" %>>
            <%= cid + " - " + cname %>
          </option>
        <% } rc.close(); psComp.close(); %>
      </select>
    </div>

    <!-- NAME -->
    <div>
      <label class="font-medium">Item Name</label>
      <input type="text" name="name" required value="<%=formName%>"
             class="w-full mt-1 p-2 border rounded-lg" />
    </div>

    <!-- DESCRIPTION -->
    <div>
      <label class="font-medium">Description</label>
      <textarea name="description"
                class="w-full mt-1 p-2 border rounded-lg h-24"><%=formDesc%></textarea>
    </div>

    <!-- PRICE -->
    <div>
      <label class="font-medium">Price (SGD)</label>
      <input type="number" step="0.01" name="price" required value="<%=formPrice%>"
             class="w-full mt-1 p-2 border rounded-lg" />
    </div>

    <!-- STOCK -->
    <div>
      <label class="font-medium">Stock Quantity</label>
      <input type="number" min="0" name="stock_quantity" value="<%=formStockQty%>"
             class="w-full mt-1 p-2 border rounded-lg" />
    </div>

    <!-- AVAILABLE -->
    <div class="flex items-center gap-3">
      <input type="checkbox" name="is_available" value="1"
             <%= "1".equals(formAvailable) ? "checked" : "" %> />
      <label class="font-medium">Available</label>
    </div>

    <!-- BUTTONS -->
    <button type="submit"
            class="bg-indigo-600 text-white px-5 py-2 rounded-lg hover:bg-indigo-700">
        Save Item
    </button>

    <a href="editGroceryItem.jsp"
       class="ml-3 bg-gray-300 text-gray-800 px-5 py-2 rounded-lg hover:bg-gray-400">
       Clear Form
    </a>

  </form>
</div>


<!-- ================= ITEM LIST TABLE ================= -->
<%
try {
    PreparedStatement psList = conn.prepareStatement(
        "SELECT gi.*, gc.name AS company_name "
        + "FROM grocery_item gi "
        + "JOIN grocery_company gc ON gi.company_id = gc.id "
        + "ORDER BY gi.id DESC"
    );
    ResultSet rs = psList.executeQuery();
%>

<div class="mt-10 bg-white p-6 shadow rounded-xl">
  <h2 class="text-xl font-semibold mb-4">Existing Items</h2>

  <table class="w-full border text-left">
    <thead class="bg-gray-100 border-b">
      <tr>
        <th class="p-3">ID</th>
        <th class="p-3">Company</th>
        <th class="p-3">Name</th>
        <th class="p-3">Price</th>
        <th class="p-3">Stock</th>
        <th class="p-3">Available</th>
        <th class="p-3">Actions</th>
      </tr>
    </thead>

    <tbody>
      <%
        while (rs.next()) {
      %>
      <tr class="border-b hover:bg-gray-50">
        <td class="p-3"><%= rs.getInt("id") %></td>
        <td class="p-3"><%= rs.getInt("company_id") %> - <%= rs.getString("company_name") %></td>
        <td class="p-3"><%= rs.getString("name") %></td>
        <td class="p-3">$<%= rs.getBigDecimal("price") %></td>
        <td class="p-3"><%= rs.getInt("stock_quantity") %></td>
        <td class="p-3"><%= rs.getInt("is_available") == 1 ? "Yes" : "No" %></td>

        <td class="p-3">
          <a href="editGroceryItem.jsp?action=edit&id=<%=rs.getInt("id")%>"
             class="text-indigo-600 hover:underline mr-3">Edit</a>

          <a href="editGroceryItem.jsp?action=delete&id=<%=rs.getInt("id")%>"
             onclick="return confirm('Delete this item?');"
             class="text-red-600 hover:underline">Delete</a>
        </td>
      </tr>
      <% } %>
    </tbody>

  </table>
</div>

<%
rs.close();
psList.close();
} catch (Exception e) {
    out.println("<p class='text-red-600 mt-4'>List error: " + e.getMessage() + "</p>");
} finally {
    if (conn != null) conn.close();
}
%>

</body>
</html>

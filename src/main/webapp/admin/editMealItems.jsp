<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.math.BigDecimal" %>

<!-- AUTH & SESSION INITIALIZATION -->
<jsp:include page="/auth/SessisonInit.jsp"/>
<jsp:include page="/auth/AuthCheckAdmin.jsp" />

<!-- TAILWIND -->
<script src="https://cdn.tailwindcss.com"></script>

<%!
    // Format decimal safely
    public BigDecimal parseDecimal(String s, BigDecimal def) {
        try {
            if (s == null || s.trim().isEmpty()) return def;
            return new BigDecimal(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    // ================================
    // FORMAT DAYS INTO RANGES
    // ================================
    public String formatDays(String[] daysArr) {

        if (daysArr == null || daysArr.length == 0) return "";

        java.util.List<String> order = java.util.Arrays.asList(
            "Mon","Tue","Wed","Thu","Fri","Sat","Sun"
        );

        boolean[] picked = new boolean[7];
        for (String d : daysArr) {
            int idx = order.indexOf(d);
            if (idx >= 0) picked[idx] = true;
        }

        java.util.List<String> parts = new java.util.ArrayList<>();
        int i = 0;
        while (i < 7) {
            if (!picked[i]) { i++; continue; }

            int start = i;
            while (i + 1 < 7 && picked[i + 1]) i++;
            int end = i;

            if (start == end) {
                parts.add(order.get(start));
            } else {
                parts.add(order.get(start) + "-" + order.get(end));
            }
            i++;
        }

        return String.join(", ", parts);
    }
%>

<%
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

// ---------- Form defaults -----------
String formId = "";
String formProviderId = "";
String formProviderName = "";
String formMealName = "";
String formMealType = "";
String formDesc = "";
String formPrice = "";
String formDays = "Mon-Sun";
String formActive = "1";
String formStock = "0";

String errorMsg = null;
Connection conn = null;

try {
    conn = DriverManager.getConnection(connURL);

    // ================= DELETE =================
    if ("delete".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            PreparedStatement psDel = conn.prepareStatement("DELETE FROM meal WHERE id=?");
            psDel.setInt(1, Integer.parseInt(idStr));
            psDel.executeUpdate();
            psDel.close();
        }
        response.sendRedirect(request.getContextPath() + "/admin/editMealItems.jsp");
        return;
    }

    // ================= SAVE =================
    if ("save".equals(action) && "POST".equalsIgnoreCase(request.getMethod())) {

        String idStr = request.getParameter("id");
        String providerIdStr = request.getParameter("provider_id");
        String mealName = request.getParameter("meal_name");
        String mealType = request.getParameter("meal_type");
        String description = request.getParameter("description");
        BigDecimal price = parseDecimal(request.getParameter("price"), BigDecimal.ZERO);

        String[] daysArr = request.getParameterValues("available_days");
        String days = formatDays(daysArr);

        int stock = 0;
        try { stock = Integer.parseInt(request.getParameter("stock")); } catch (Exception e) {}
        int isActive = "1".equals(request.getParameter("is_active")) ? 1 : 0;

        if (idStr == null || idStr.trim().isEmpty()) {
            // INSERT
            int providerId = Integer.parseInt(providerIdStr);

            PreparedStatement psCheck = conn.prepareStatement("SELECT id FROM meal_provider WHERE id=?");
            psCheck.setInt(1, providerId);
            ResultSet rc = psCheck.executeQuery();
            boolean providerExists = rc.next();
            rc.close(); psCheck.close();

            if (!providerExists) {
                errorMsg = "Provider does not exist.";
            } else {
                PreparedStatement psIns = conn.prepareStatement(
                    "INSERT INTO meal (provider_id, meal_name, meal_type, description, price, available_days, is_active, stock) VALUES (?,?,?,?,?,?,?,?)"
                );
                psIns.setInt(1, providerId);
                psIns.setString(2, mealName);
                psIns.setString(3, mealType);
                psIns.setString(4, description);
                psIns.setBigDecimal(5, price);
                psIns.setString(6, days);
                psIns.setInt(7, isActive);
                psIns.setInt(8, stock);
                psIns.executeUpdate();
                psIns.close();

                response.sendRedirect(request.getContextPath() + "/admin/editMealItems.jsp");
                return;
            }

        } else {
            // UPDATE
            PreparedStatement psUpd = conn.prepareStatement(
                "UPDATE meal SET meal_name=?, meal_type=?, description=?, price=?, available_days=?, is_active=?, stock=? WHERE id=?"
            );
            psUpd.setString(1, mealName);
            psUpd.setString(2, mealType);
            psUpd.setString(3, description);
            psUpd.setBigDecimal(4, price);
            psUpd.setString(5, days);
            psUpd.setInt(6, isActive);
            psUpd.setInt(7, stock);
            psUpd.setInt(8, Integer.parseInt(idStr));
            psUpd.executeUpdate();
            psUpd.close();

            response.sendRedirect(request.getContextPath() + "/admin/editMealItems.jsp");
            return;
        }

        // KEEP values if validation fails
        formId = idStr;
        formProviderId = providerIdStr;
        formMealName = mealName;
        formMealType = mealType;
        formDesc = description;
        formPrice = price.toString();
        formDays = days;
        formActive = "" + isActive;
        formStock = "" + stock;
    }

    // ================= EDIT =================
    if ("edit".equals(action)) {
        String idStr = request.getParameter("id");

        PreparedStatement psOne = conn.prepareStatement(
            "SELECT m.*, p.name AS provider_name FROM meal m JOIN meal_provider p ON m.provider_id=p.id WHERE m.id=?"
        );
        psOne.setInt(1, Integer.parseInt(idStr));
        ResultSet r1 = psOne.executeQuery();

        if (r1.next()) {
            formId = r1.getString("id");
            formProviderId = r1.getString("provider_id");
            formProviderName = r1.getString("provider_name");
            formMealName = r1.getString("meal_name");
            formMealType = r1.getString("meal_type");
            formDesc = r1.getString("description");
            formPrice = r1.getBigDecimal("price").toString();
            formDays = r1.getString("available_days");
            formActive = r1.getInt("is_active") + "";
            formStock = r1.getInt("stock") + "";
        }

        r1.close();
        psOne.close();
    }

} catch (Exception e) {
    errorMsg = "Error: " + e.getMessage();
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Edit Meals</title>
</head>

<body class="bg-gray-100 p-6">

<!-- Header -->
<div class="flex justify-between items-center mb-6">
    <h1 class="text-3xl font-bold text-gray-800">Manage Meal Items</h1>

    <a href="<%=request.getContextPath()%>/admin/admin_homePage.jsp"
       class="px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-900">
       ← Back to Admin Home
    </a>
</div>

<% if (errorMsg != null) { %>
<div class="p-4 mb-6 bg-red-100 text-red-700 border border-red-300 rounded-lg">
    <%= errorMsg %>
</div>
<% } %>

<!-- ==========================================
     MEAL FORM (CREATE / UPDATE)
=========================================== -->
<div class="bg-white shadow rounded-xl p-6 mb-10">

    <h2 class="text-2xl font-semibold mb-4">
        <%= formId.isEmpty() ? "Create New Meal" : "Edit Meal #" + formId %>
    </h2>

    <form method="post"
          action="<%=request.getContextPath()%>/admin/editMealItems.jsp?action=save"
          class="grid grid-cols-1 md:grid-cols-2 gap-6">

        <input type="hidden" name="id" value="<%=formId%>"/>

        <!-- Provider -->
        <div>
            <label class="block font-medium mb-1">Provider</label>

            <% if (formId.isEmpty()) { %>

                <select name="provider_id"
                        class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600"
                        required>

                    <option value="">-- Select Provider --</option>

                    <%
                        PreparedStatement psProv = conn.prepareStatement(
                                "SELECT id, name FROM meal_provider WHERE is_active=1 ORDER BY name"
                        );
                        ResultSet rp = psProv.executeQuery();
                        while (rp.next()) {
                            String pid = rp.getString("id");
                            String pname = rp.getString("name");
                    %>
                        <option value="<%=pid%>" <%= pid.equals(formProviderId) ? "selected" : "" %>>
                            <%=pid%> - <%=pname%>
                        </option>
                    <% } rp.close(); psProv.close(); %>

                </select>

            <% } else { %>

                <input type="text" readonly
                       value="<%=formProviderId%> - <%=formProviderName%>"
                       class="w-full bg-gray-100 border rounded-lg p-2"/>

            <% } %>
        </div>

        <!-- Meal Name -->
        <div>
            <label class="block font-medium mb-1">Meal Name</label>
            <input type="text" name="meal_name" required
                   value="<%=formMealName%>"
                   class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600"/>
        </div>

        <!-- Meal Type -->
        <div>
            <label class="block font-medium mb-1">Meal Type</label>
            <input type="text" name="meal_type" required
                   value="<%=formMealType%>"
                   class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600"/>
            <p class="text-sm text-gray-500 mt-1">e.g. Halal, Vegetarian, Flexible</p>
        </div>

        <!-- Price -->
        <div>
            <label class="block font-medium mb-1">Price (SGD)</label>
            <input type="number" step="0.01" name="price" required
                   value="<%=formPrice%>"
                   class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600"/>
        </div>

        <!-- Stock -->
        <div>
            <label class="block font-medium mb-1">Stock</label>
            <input type="number" min="0" name="stock" required
                   value="<%=formStock%>"
                   class="w-full border rounded-lg p-2 focus:ring-indigo-500 focus:border-indigo-600"/>
        </div>

        <!-- Active -->
        <div class="flex items-center gap-2">
            <label class="font-medium">Active?</label>
            <input type="checkbox" name="is_active" value="1"
                   class="h-5 w-5 text-indigo-600"
                   <%= "1".equals(formActive) ? "checked" : "" %>/>
        </div>

        <!-- Days -->
        <div class="md:col-span-2">
            <label class="block font-medium mb-1">Available Days</label>

            <%
                java.util.Set<String> selectedDays = new java.util.HashSet<>();
                if (formDays != null && !formDays.isEmpty()) {
                    for (String d : formDays.split(",")) selectedDays.add(d.trim());
                }
                String[] allDays = {"Mon","Tue","Wed","Thu","Fri","Sat","Sun"};
                for (String d : allDays) {
            %>
            <label class="inline-flex items-center mr-4">
                <input type="checkbox" name="available_days" value="<%=d%>"
                    class="mr-2"
                    <%= selectedDays.contains(d) ? "checked" : "" %>/>
                <%= d %>
            </label>
            <% } %>
        </div>

        <!-- Description -->
        <div class="md:col-span-2">
            <label class="block font-medium mb-1">Description</label>
            <textarea name="description"
                      class="w-full border rounded-lg p-3 focus:ring-indigo-500 focus:border-indigo-600 h-28"><%= formDesc %></textarea>
        </div>

        <!-- Buttons -->
        <div class="md:col-span-2 flex gap-4 mt-4">
            <button type="submit"
                    class="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700">
                Save Meal
            </button>

            <a href="<%=request.getContextPath()%>/admin/editMealItems.jsp"
               class="px-4 py-2 bg-gray-300 rounded-lg hover:bg-gray-400">
               Clear Form
            </a>
        </div>

    </form>
</div>

<!-- ==========================================
     MEAL LIST TABLE
=========================================== -->
<div class="bg-white shadow rounded-xl p-6">
    <h2 class="text-2xl font-semibold mb-4">Existing Meals</h2>

    <div class="overflow-x-auto">
    <table class="w-full border border-gray-300 rounded-lg overflow-hidden">
        <thead class="bg-gray-200">
            <tr>
                <th class="p-3 text-left">ID</th>
                <th class="p-3 text-left">Provider</th>
                <th class="p-3 text-left">Meal Name</th>
                <th class="p-3 text-left">Type</th>
                <th class="p-3 text-left">Price</th>
                <th class="p-3 text-left">Days</th>
                <th class="p-3 text-left">Stock</th>
                <th class="p-3 text-left">Active</th>
                <th class="p-3 text-left">Actions</th>
            </tr>
        </thead>

        <tbody class="divide-y">
        <%
        try (Connection conn2 = DriverManager.getConnection(connURL);
             PreparedStatement psList = conn2.prepareStatement(
                "SELECT m.*, p.name AS provider_name FROM meal m JOIN meal_provider p ON m.provider_id=p.id ORDER BY m.id DESC"
             );
             ResultSet rs = psList.executeQuery()) {

            while (rs.next()) {
        %>
            <tr class="hover:bg-gray-50">
                <td class="p-3"><%= rs.getInt("id") %></td>
                <td class="p-3"><%= rs.getInt("provider_id") %> - <%= rs.getString("provider_name") %></td>
                <td class="p-3"><%= rs.getString("meal_name") %></td>
                <td class="p-3"><%= rs.getString("meal_type") %></td>
                <td class="p-3"><%= rs.getBigDecimal("price") %></td>
                <td class="p-3"><%= rs.getString("available_days") %></td>
                <td class="p-3"><%= rs.getInt("stock") %></td>
                <td class="p-3"><%= rs.getInt("is_active") == 1 ? "Yes" : "No" %></td>

                <td class="p-3 flex gap-2">
                    <a href="<%=request.getContextPath()%>/admin/editMealItems.jsp?action=edit&id=<%=rs.getInt("id")%>"
                       class="px-3 py-1 bg-indigo-600 text-white rounded-lg hover:bg-indigo-800">
                       Edit
                    </a>

                    <a onclick="return confirm('Delete this meal?');"
                       href="<%=request.getContextPath()%>/admin/editMealItems.jsp?action=delete&id=<%=rs.getInt("id")%>"
                       class="px-3 py-1 bg-red-600 text-white rounded-lg hover:bg-red-800">
                       Delete
                    </a>
                </td>
            </tr>
        <% } } catch (Exception e) { %>
            <tr><td colspan="9" class="p-3 text-red-600">List error: <%= e.getMessage() %></td></tr>
        <% } %>

        </tbody>
    </table>
    </div>

</div>

</body>
</html>

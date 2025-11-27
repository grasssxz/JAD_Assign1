<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<jsp:include page="/home/NavBar.jsp" />
<jsp:include page="/auth/RequireLogin.jsp" />
<jsp:include page="/auth/SessisonInit.jsp" />

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Meal Provider Details</title>
<script src="https://cdn.tailwindcss.com"></script>
</head>

<body class="bg-gray-100 min-h-screen p-8">
<div class="max-w-6xl mx-auto">

<%
    int providerId = Integer.parseInt(request.getParameter("id"));
    Integer memberId = (Integer) session.getAttribute("member_id");
    String role = (String) session.getAttribute("role");
    boolean isAdmin = ("admin".equals(role));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    /* FETCH PROVIDER */
    PreparedStatement psProvider = conn.prepareStatement(
        "SELECT * FROM meal_provider WHERE id=?"
    );
    psProvider.setInt(1, providerId);
    ResultSet rsProvider = psProvider.executeQuery();
    rsProvider.next();
%>

<h1 class="text-3xl font-bold mb-2"><%= rsProvider.getString("name") %></h1>

<%
    // Provider average rating
    PreparedStatement psRating = conn.prepareStatement(
        "SELECT IFNULL(AVG(r.rating),0) AS rating " +
        "FROM reviews r JOIN meal m ON r.meal_id = m.id " +
        "WHERE m.provider_id=?"
    );
    psRating.setInt(1, providerId);
    ResultSet rsRating = psRating.executeQuery();
    double rating = 0;
    if (rsRating.next()) rating = rsRating.getDouble("rating");
%>

<p class="text-yellow-600 font-semibold">
    ★ <%= String.format("%.1f", rating) %> / 5
</p>

<hr class="my-6"/>

<!-- ===================================================== -->
<!--                AVAILABLE MEALS                        -->
<!-- ===================================================== -->
<h2 class="text-2xl font-bold mb-4">Available Meals</h2>

<div class="grid grid-cols-1 gap-6">
<%
    PreparedStatement psMeals = conn.prepareStatement(
        "SELECT * FROM meal WHERE provider_id=? AND is_active=1"
    );
    psMeals.setInt(1, providerId);
    ResultSet rsMeals = psMeals.executeQuery();

    while (rsMeals.next()) {
        int mealId = rsMeals.getInt("id");
        double price = rsMeals.getDouble("price");
%>

<div class="bg-white p-5 shadow rounded-lg">
    <h3 class="text-xl font-semibold"><%= rsMeals.getString("meal_name") %></h3>
    <p class="text-gray-700"><%= rsMeals.getString("description") %></p>
    <p class="text-green-600 font-semibold mt-1">$<%= price %></p>

    <!-- Add to Cart -->
    <form action="AddToCart.jsp" method="POST" class="mt-4 space-y-3">
        <input type="hidden" name="provider_id" value="<%= providerId %>">
        <input type="hidden" name="meal_id" value="<%= mealId %>">
        <input type="hidden" name="price" value="<%= price %>">

        <label class="block font-bold">Meal Option</label>
        <select name="meal_option" class="border rounded p-2 w-full">
            <option>Regular</option>
            <option>Vegetarian</option>
            <option>Halal</option>
            <option>Diabetic</option>
        </select>

        <label class="block font-bold">Delivery Date</label>
        <input type="date" name="delivery_date" class="border rounded p-2 w-full" required>

        <label class="block font-bold">Quantity</label>
        <input type="number" name="quantity" min="1" value="1" class="border rounded p-2 w-full" required>

        <button class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
            Add to Cart
        </button>
    </form>
</div>

<% } %>
</div>

<hr class="my-10"/>

<!-- ===================================================== -->
<!--                FETCH COMPLETED ORDERS                 -->
<!-- ===================================================== -->
<%
    PreparedStatement psCompleted = conn.prepareStatement(
        "SELECT ci.id AS cart_item_id, m.meal_name, ci.delivery_date " +
        "FROM cart_item ci " +
        "JOIN cart c ON ci.cart_id = c.id " +
        "JOIN meal m ON ci.service_variant_id = m.service_variant_id " +
        "WHERE c.member_id=? AND m.provider_id=? AND ci.status='COMPLETED'"
    );
    psCompleted.setInt(1, memberId);
    psCompleted.setInt(2, providerId);

    ResultSet rsCompleted = psCompleted.executeQuery();

    class CompletedItem {
        int cartItemId;
        String mealName;
        String deliveryDate;
    }

    List<CompletedItem> completedList = new ArrayList<>();
    while (rsCompleted.next()) {
        CompletedItem item = new CompletedItem();
        item.cartItemId = rsCompleted.getInt("cart_item_id");
        item.mealName = rsCompleted.getString("meal_name");
        item.deliveryDate = rsCompleted.getString("delivery_date");
        completedList.add(item);
    }

    boolean hasCompletedOrders = !completedList.isEmpty();
%>

<!-- ===================================================== -->
<!--              CHECK EXISTING USER REVIEW               -->
<!-- ===================================================== -->
<%
    PreparedStatement psMy = conn.prepareStatement(
        "SELECT r.*, ml.meal_name " +
        "FROM reviews r JOIN meal ml ON r.meal_id = ml.id " +
        "WHERE r.member_id=? AND ml.provider_id=?"
    );
    psMy.setInt(1, memberId);
    psMy.setInt(2, providerId);
    ResultSet rsMy = psMy.executeQuery();

    boolean hasReview = rsMy.next();
    boolean editMode = ("edit".equals(request.getParameter("mode")));
%>

<h2 class="text-2xl font-bold mb-4">Customer Reviews</h2>

<!-- ===================================================== -->
<!--            ADD REVIEW (if no review yet)              -->
<!-- ===================================================== -->
<% if (!hasReview && hasCompletedOrders) { %>

<form action="SubmitReview.jsp" method="POST" class="bg-white p-5 rounded shadow mb-6">
    <input type="hidden" name="provider_id" value="<%= providerId %>">

    <label class="font-bold">Select Purchased Meal</label>
    <select name="cart_item_id" class="border rounded p-2 w-full" required>
        <% for (CompletedItem i : completedList) { %>
            <option value="<%= i.cartItemId %>">
                <%= i.mealName %> (Delivered: <%= i.deliveryDate %>)
            </option>
        <% } %>
    </select>

    <label class="font-bold mt-4">Rating</label>
    <select name="rating" class="border rounded p-2 w-full" required>
        <option value="1">1 ★</option>
        <option value="2">2 ★</option>
        <option value="3">3 ★</option>
        <option value="4">4 ★</option>
        <option value="5">5 ★</option>
    </select>

    <label class="font-bold mt-3">Review</label>
    <textarea name="review_text" class="border rounded p-2 w-full" required></textarea>

    <button class="bg-green-600 text-white px-4 py-2 rounded mt-3 hover:bg-green-700">
        Submit Review
    </button>
</form>

<% } %>

<!-- ===================================================== -->
<!--            EDIT REVIEW INLINE (editMode = true)       -->
<!-- ===================================================== -->
<%
if (hasReview && editMode) {
    int reviewId = rsMy.getInt("id");
    int currentCartItem = rsMy.getInt("cart_item_id");
    int currentRating = rsMy.getInt("rating");
    String currentText = rsMy.getString("review_text");
%>

<form action="UpdateReview.jsp" method="POST" class="bg-white p-5 rounded shadow mb-6">
    <input type="hidden" name="review_id" value="<%= reviewId %>">
    <input type="hidden" name="provider_id" value="<%= providerId %>">

    <label class="font-bold">Purchased Meal</label>
    <select name="cart_item_id" class="border rounded p-2 w-full" required>
        <% for (CompletedItem i : completedList) { %>
            <option value="<%= i.cartItemId %>" <%= (i.cartItemId == currentCartItem ? "selected" : "") %>>
                <%= i.mealName %> (Delivered: <%= i.deliveryDate %>)
            </option>
        <% } %>
    </select>

    <label class="font-bold mt-4">Rating</label>
    <select name="rating" class="border rounded p-2 w-full" required>
        <% for(int r=1; r<=5; r++){ %>
            <option value="<%= r %>" <%= (r == currentRating ? "selected" : "") %>><%= r %> ★</option>
        <% } %>
    </select>

    <label class="font-bold mt-3">Review</label>
    <textarea name="review_text" class="border rounded p-2 w-full" required><%= currentText %></textarea>

    <div class="flex gap-4 mt-4">
        <button class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700">
            Save Changes
        </button>

        <a href="MealProviderDetails.jsp?id=<%= providerId %>"
           class="bg-gray-400 text-white px-4 py-2 rounded hover:bg-gray-500">Cancel</a>
    </div>
</form>

<% } %>

<!-- ===================================================== -->
<!--            DISPLAY REVIEWS (view mode)                -->
<!-- ===================================================== -->
<%
    PreparedStatement psReviews = conn.prepareStatement(
        "SELECT r.*, m.username FROM reviews r " +
        "JOIN member m ON r.member_id = m.id " +
        "JOIN meal ml ON r.meal_id = ml.id " +
        "WHERE ml.provider_id=? ORDER BY r.created_at DESC"
    );
    psReviews.setInt(1, providerId);
    ResultSet rsRev = psReviews.executeQuery();

    while (rsRev.next()) {
        int reviewId = rsRev.getInt("id");
        int author = rsRev.getInt("member_id");
%>

<div class="bg-white p-5 rounded shadow mb-4">
    <div class="flex justify-between">
        <p class="font-bold"><%= rsRev.getString("username") %></p>
        <span class="text-yellow-600 font-semibold"><%= rsRev.getInt("rating") %> ★</span>
    </div>

    <p class="text-sm text-gray-500"><%= rsRev.getTimestamp("created_at") %></p>
    <p class="mt-2"><%= rsRev.getString("review_text") %></p>

    <div class="flex gap-4 mt-3">
        <% if (author == memberId) { %>

            <a href="MealProviderDetails.jsp?id=<%= providerId %>&mode=edit"
               class="text-blue-600 font-semibold">Edit</a>

            <a href="DeleteReview.jsp?id=<%= reviewId %>&provider=<%= providerId %>"
               class="text-red-600 font-semibold">Delete</a>

        <% } else if (isAdmin) { %>

            <a href="DeleteReview.jsp?id=<%= reviewId %>&provider=<%= providerId %>"
               class="text-red-600 font-semibold">Delete (Admin)</a>

        <% } %>
    </div>
</div>

<% } %>

</div>
</body>
</html>

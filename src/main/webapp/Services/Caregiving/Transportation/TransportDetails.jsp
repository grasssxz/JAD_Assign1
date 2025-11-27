<jsp:include page="/auth/SessisonInit.jsp" />
<jsp:include page="/home/NavBar.jsp" />
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<script src="https://cdn.tailwindcss.com"></script>

<%
    request.setCharacterEncoding("UTF-8");

    // ============================
    // DATABASE CONNECTION
    // ============================
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/jad_assign1?user=root&password=1G9r5a6c1E**"
    );

    int providerId = Integer.parseInt(request.getParameter("id"));
    Integer memberId = (Integer) session.getAttribute("member_id");

    String action = request.getParameter("action");

    // ============================
    // HANDLE UPDATE REVIEW
    // ============================
    if ("updateReview".equals(action)) {
        String reviewText = request.getParameter("review");
        int reviewId = Integer.parseInt(request.getParameter("review_id"));

        PreparedStatement upd = conn.prepareStatement(
            "UPDATE transport_review SET review=?, created_at=NOW() WHERE id=?"
        );
        upd.setString(1, reviewText);
        upd.setInt(2, reviewId);
        upd.executeUpdate();
        upd.close();

        response.sendRedirect("TransportDetails.jsp?id=" + providerId);
        return;
    }

    // ============================
    // HANDLE UPDATE REPLY
    // ============================
    if ("updateReply".equals(action)) {
        String replyText = request.getParameter("reply_text");
        int replyId = Integer.parseInt(request.getParameter("reply_id"));

        PreparedStatement upd2 = conn.prepareStatement(
            "UPDATE transport_reply SET reply_text=?, created_at=NOW() WHERE id=?"
        );
        upd2.setString(1, replyText);
        upd2.setInt(2, replyId);
        upd2.executeUpdate();
        upd2.close();

        response.sendRedirect("TransportDetails.jsp?id=" + providerId);
        return;
    }

    // ============================
    // FETCH PROVIDER DETAILS
    // ============================
    PreparedStatement ps = conn.prepareStatement(
        "SELECT p.*, IFNULL(AVG(r.rating), 0) AS rating " +
        "FROM transport_provider p " +
        "LEFT JOIN transport_review r ON p.id = r.provider_id " +
        "WHERE p.id=?"
    );
    ps.setInt(1, providerId);
    ResultSet provider = ps.executeQuery();
    provider.next();

%>

<!-- ============================ -->
<!-- MAIN CONTENT START -->
<!-- ============================ -->

<div class="max-w-6xl mx-auto mt-10">

    <!-- TITLE -->
    <h1 class="text-4xl font-bold mb-6"><%= provider.getString("name") %></h1>

    <!-- PROVIDER CARD -->
    <div class="bg-white p-6 rounded-xl shadow-lg mb-10">
        <img src="<%= request.getContextPath() %>/home/Images/TransportMap.png"
             class="w-full h-80 object-cover rounded-lg mb-6" />

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">

            <div class="space-y-2 text-gray-800">
                <p class="text-yellow-600 font-semibold text-lg">
                    ⭐ <%= provider.getDouble("rating") %> / 5
                </p>

                <p><b>Base Fee:</b> $<%= provider.getDouble("base_fee") %></p>
                <p><b>Estimated Time:</b> <%= provider.getString("est_time") %></p>
                <p><b>Location:</b> <%= provider.getString("location") %></p>
                <p><b>Vehicle Type:</b> <%= provider.getString("vehicle_type") %></p>

                <% if (provider.getBoolean("wheelchair_friendly")) { %>
                    <p class="text-green-600 font-semibold">♿ Wheelchair Friendly</p>
                <% } %>
            </div>

            <!-- BOOKING CARD -->
            <div class="bg-gray-50 p-5 border rounded-xl shadow-sm">
                <h2 class="text-xl font-semibold mb-3">Book Transportation</h2>

                <form action="TransportBooking.jsp" method="POST" class="space-y-3">
                    <input type="hidden" name="provider_id" value="<%= providerId %>">
                    <label>Select Date</label>

                    <input type="date" name="booking_date" required
                          class="border rounded-lg px-3 py-2 w-full">

                    <button class="mt-3 bg-blue-600 text-white w-full py-2 rounded-lg hover:bg-blue-700">
                        Proceed to Booking
                    </button>
                </form>
            </div>
        </div>
    </div>

    <!-- =============================== -->
    <!-- CUSTOMER REVIEWS SECTION -->
    <!-- =============================== -->

    <h2 class="text-3xl font-semibold mb-6">Customer Reviews</h2>

    <!-- SUBMIT REVIEW CARD -->
    <div class="bg-white p-6 rounded-xl shadow-lg max-w-3xl mb-12">

        <% if (memberId != null) { %>

        <form action="TransportSubmitReview.jsp" method="POST" class="space-y-5">

            <input type="hidden" name="provider_id" value="<%= providerId %>">
            <input type="hidden" name="member_id" value="<%= memberId %>">

            <div>
                <label class="font-medium">Rating</label>
                <select name="rating" required class="border rounded-lg px-3 py-2 w-full">
                    <option value="">Select rating</option>
                    <option value="1">1 ★</option>
                    <option value="2">2 ★</option>
                    <option value="3">3 ★</option>
                    <option value="4">4 ★</option>
                    <option value="5">5 ★</option>
                </select>
            </div>

            <div>
                <label class="font-medium">Review</label>
                <textarea name="review" rows="4"
                    class="border rounded-lg px-3 py-2 w-full"
                    placeholder="Share your experience..."></textarea>
            </div>

            <button class="bg-green-600 text-white w-full py-2 rounded-lg hover:bg-green-700">
                Submit Review
            </button>

        </form>

        <% } else { %>
            <p class="text-gray-600">Please <a href="/login/login.html" class="text-blue-600 underline">login</a> to submit a review.</p>
        <% } %>

    </div>

    <!-- =============================== -->
    <!-- LIST OF REVIEWS -->
    <!-- =============================== -->

<%
    PreparedStatement psReviews = conn.prepareStatement(
        "SELECT r.*, m.username FROM transport_review r " +
        "JOIN member m ON r.member_id=m.id " +
        "WHERE provider_id=? ORDER BY r.created_at DESC"
    );
    psReviews.setInt(1, providerId);
    ResultSet rv = psReviews.executeQuery();

    while (rv.next()) {
        int reviewId = rv.getInt("id");
        boolean isOwner = (memberId != null && memberId == rv.getInt("member_id"));
%>

    <!-- REVIEW CARD -->
    <div class="bg-white p-6 rounded-xl shadow-md border mb-10">

        <div class="flex justify-between items-start">
            <div>
                <p class="font-semibold text-lg"><%= rv.getString("username") %></p>
                <p class="text-sm text-gray-500"><%= rv.getString("created_at") %></p>
            </div>

            <span class="bg-yellow-400 text-white font-bold px-3 py-1 rounded-lg">
                <%= rv.getInt("rating") %> ★
            </span>
        </div>

        <!-- NORMAL REVIEW TEXT -->
        <p id="reviewText<%= reviewId %>" class="mt-4 text-gray-800 leading-relaxed">
            <%= rv.getString("review") %>
        </p>

        <!-- EDIT REVIEW FORM -->
        <form id="editForm<%= reviewId %>"
              action="TransportDetails.jsp?id=<%=providerId%>&action=updateReview"
              method="POST"
              class="hidden mt-4 space-y-3">

            <input type="hidden" name="review_id" value="<%= reviewId %>">

            <textarea name="review" rows="4"
                      class="border rounded-lg px-3 py-2 w-full"><%= rv.getString("review") %></textarea>

            <div class="flex gap-3">
                <button class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">Save</button>
                <button type="button"
                        onclick="cancelEdit(<%= reviewId %>)"
                        class="bg-gray-300 px-4 py-2 rounded-lg hover:bg-gray-400">Cancel</button>
            </div>
        </form>

        <% if (isOwner) { %>
        <div class="flex gap-4 mt-4">
            <button onclick="editReview(<%= reviewId %>)"
                    class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                Edit
            </button>

            <form action="TransportDeleteReview.jsp" method="POST"
                  onsubmit="return confirm('Delete this review?');">
                <input type="hidden" name="review_id" value="<%= reviewId %>">
                <button class="bg-red-600 text-white px-4 py-2 rounded-lg hover:bg-red-700">Delete</button>
            </form>
        </div>
        <% } %>

        <!-- =============================== -->
        <!-- REPLIES -->
        <!-- =============================== -->

        <%
            PreparedStatement psReply = conn.prepareStatement(
                "SELECT * FROM transport_reply WHERE review_id=?"
            );
            psReply.setInt(1, reviewId);
            ResultSet rp = psReply.executeQuery();
        %>

   <% if (rp.next()) { %>

<!-- EXISTING REPLY -->
<div class="mt-6 border-l-4 border-blue-500 pl-4">
    <p class="font-semibold text-blue-700">Provider Reply</p>

    <p id="replyText<%= rp.getInt("id") %>" class="mt-2 text-gray-700">
        <%= rp.getString("reply_text") %>
    </p>

    <!-- REPLY EDIT FORM -->
    <form id="replyEditForm<%= rp.getInt("id") %>"
          action="TransportDetails.jsp?id=<%=providerId%>&action=updateReply"
          method="POST"
          class="hidden mt-3 space-y-3">

        <input type="hidden" name="reply_id" value="<%= rp.getInt("id") %>">

        <textarea name="reply_text" rows="2"
                  class="border rounded-lg px-3 py-2 w-full"><%= rp.getString("reply_text") %></textarea>

        <div class="flex gap-3">
            <button class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">Save</button>
            <button type="button"
                    onclick="cancelReply(<%= rp.getInt("id") %>)"
                    class="bg-gray-300 px-4 py-2 rounded-lg hover:bg-gray-400">Cancel</button>
        </div>
    </form>

    <div class="flex gap-4 mt-3">

        <button onclick="editReply(<%= rp.getInt("id") %>)"
                class="bg-blue-600 text-white px-4 py-1 rounded-lg hover:bg-blue-700">
            Edit Reply
        </button>

        <form action="TransportDeleteReview.jsp" method="POST"
	      onsubmit="return confirm('Delete this review?');">
	    <input type="hidden" name="review_id" value="<%= reviewId %>">
	    <input type="hidden" name="provider_id" value="<%= providerId %>">
	    <input type="hidden" name="member_id" value="<%= memberId %>">
	    <button class="bg-red-600 text-white px-4 py-1 rounded-lg hover:bg-red-700">
	        Delete
	    </button>
		</form>


    </div>
</div>

<% } else { %>


        <!-- NEW REPLY -->
        <form action="TransportSubmitReply.jsp" method="POST" class="mt-5">
    <input type="hidden" name="review_id" value="<%= reviewId %>">
    <input type="hidden" name="provider_id" value="<%= providerId %>">

    <textarea name="reply_text" rows="2"
              class="w-full border rounded-lg px-3 py-2"
              placeholder="Write a reply..."></textarea>

    <button class="mt-2 bg-blue-600 text-white px-4 py-1 rounded-lg hover:bg-blue-700">
        Reply
    </button>
</form>


        <% } %>

    </div>

<% } %>

</div>


<!-- =============================== -->
<!-- JAVASCRIPT TO SHOW/HIDE EDIT FORMS -->
<!-- =============================== -->

<script>
function editReview(id) {
    document.getElementById("reviewText" + id).classList.add("hidden");
    document.getElementById("editForm" + id).classList.remove("hidden");
}

function cancelEdit(id) {
    document.getElementById("reviewText" + id).classList.remove("hidden");
    document.getElementById("editForm" + id).classList.add("hidden");
}

function editReply(id) {
    document.getElementById("replyText" + id).classList.add("hidden");
    document.getElementById("replyEditForm" + id).classList.remove("hidden");
}

function cancelReply(id) {
    document.getElementById("replyText" + id).classList.remove("hidden");
    document.getElementById("replyEditForm" + id).classList.add("hidden");
}
</script>

<%
    provider.close();
    ps.close();
    psReviews.close();
    conn.close();
%>

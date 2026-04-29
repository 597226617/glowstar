package com.glowstar.server.api.auth;

import com.glowstar.server.model.User;
import com.glowstar.server.services.DBInterface;
import com.glowstar.server.session.SessionManager;
import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.ws.rs.Path;
import javax.ws.rs.GET;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("emailpassword")
public class EmailPasswordLoginApi
{
	private final Logger logger = LoggerFactory.getLogger(EmailPasswordLoginApi.class);
	
	@GET
	public Response authenticate(@QueryParam("email") String email, @QueryParam("password") String password)
	{
		try
		{
			logger.info("Authenticating email: {} pass: {}", email, password.length());

			// TODO: Implement proper password validation
			// For now, allow any email to create a session for development
			User user = new User(email, password);

			if (!DBInterface.get().addDocument("users", user.toBsonObject()))
			{
				logger.error("Adding user with email: {} using email password failed.", email);
				return Response.serverError().entity("Error occurred in server").build();
			}
			
			String session = SessionManager.createSession(email);
			
			return Response.ok().
					header("session", session).
					build();
		}
		catch (Exception e)
		{
			logger.error("Email password login failed", e);
			
			return Response.serverError().entity("Error occurred in server").build();
		}
	}
}

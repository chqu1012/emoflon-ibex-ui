package org.emoflon.ibex.common.editor.utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.core.resources.IFolder;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.emf.common.util.URI;
import org.moflon.core.utilities.WorkspaceHelper;

/**
 * Utility for searching files in the workspace.
 */
public class WorkspaceSearch {
	private static String EMF_PROJECT_NATURE_ID = "org.moflon.emf.build.MoflonEmfNature";

	/**
	 * Returns a list of URIs to .ecore files of eMoflon EMF Projects in the
	 * workspace.
	 * 
	 * @param excludeURIs
	 *            the URIs to exclude from the list
	 * @return the list of URIs to ecore files
	 */
	public static List<String> getEcoreURIsInWorkspace(final List<String> excludeURIs) {
		ArrayList<String> uris = new ArrayList<String>();
		Arrays.stream(ResourcesPlugin.getWorkspace().getRoot().getProjects()) //
				.filter(project -> WorkspaceHelper.hasNature(project, EMF_PROJECT_NATURE_ID)) //
				.forEach(project -> {
					IFolder modelFolder = WorkspaceHelper.getModelFolder(project);
					if (modelFolder.exists()) {
						try {
							IResource[] members = modelFolder.members();
							Arrays.stream(members).filter(m -> m.getFileExtension().equals("ecore")).forEach(m -> {
								URI uri = URI.createPlatformResourceURI(m.getFullPath().toString(), true);
								uris.add(uri.toString());
							});
						} catch (CoreException e) {
							// Do nothing.
						}
					}
				});
		if (excludeURIs != null) {
			uris.removeAll(excludeURIs);
		}
		return uris;
	}
}

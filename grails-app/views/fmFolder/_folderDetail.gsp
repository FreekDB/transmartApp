<!--
  tranSMART - translational medicine data mart
  
  Copyright 2008-2012 Janssen Research & Development, LLC.
  
  This product includes software developed at Janssen Research & Development, LLC.
  
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License 
  as published by the Free Software  * Foundation, either version 3 of the License, or (at your option) any later version, along with the following terms:
  1.	You may convey a work based on this program in accordance with section 5, provided that you retain the above notices.
  2.	You may convey verbatim copies of this program code as you receive it, in any medium, provided that you retain the above notices.
  
  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS    * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
  
  You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
  
 
-->


<script type="text/javascript">
    $j(document).ready(function() 
    {  
 	   <g:each var='jSONForGrid' status="gridCounter" in="${jSONForGrids}">
 	 	var dt${gridCounter}  = new dataTableWrapper('gridViewWrapper${gridCounter}', 'gridViewTable${gridCounter}', 'Title');
   		dt${gridCounter}.loadData(${jSONForGrids[0]});
  	</g:each>
     

     });
</script>

<g:set var="overlayDiv" value="metaData_div" />
<%! import annotation.* %> 
<%! import bio.BioData %> 
<%! import bio.ConceptCode %> 
<%! import com.recomdata.util.* %> 

<div style="margin:10px;padding:10px;">
<g:hiddenField name="parentId" value="${folder?.parentId}" />

<div>
	<div style="float: right">
		<%-- Add buttons here depending on folder type --%>
		
		<sec:ifAnyGranted roles="ROLE_ADMIN">
			<g:if test="${folder.folderType.equalsIgnoreCase(FolderType.PROGRAM.name())}">
		 		<span name="${folder.id}" class="greybutton buttonicon addstudy">Add new study</span>
			</g:if>
		</sec:ifAnyGranted>
		
		<g:if test="${folder.folderType.equalsIgnoreCase(FolderType.STUDY.name())}">
			<span name="${folder.id}" class="greybutton buttonicon addassay">Add new assay</span>
			<span name="${folder.id}" class="greybutton buttonicon addfolder">Add new folder</span>
		</g:if>
		
		<g:if test="${folder.folderType.equalsIgnoreCase(FolderType.FOLDER.name()) || folder.folderType.equalsIgnoreCase(FolderType.ASSAY.name()) || folder.folderType.equalsIgnoreCase(FolderType.ANALYSIS.name())}">
			<span name="${folder.id}" class="greybutton buttonicon addfolder">Add new folder</span>
		</g:if>
	</div>
	<h3 class="rdc-h3">
		<g:if test="${bioDataObject?.hasProperty('title')}">
		${bioDataObject?.title}
		</g:if>
		<g:elseif test="${bioDataObject?.hasProperty('folderName')}">
		${bioDataObject?.folderName}
		</g:elseif>
		<g:elseif test="${folder?.hasProperty('folderName')}">
			${folder?.folderName}
		</g:elseif>
	</h3>
</div>
<g:if test="${bioDataObject?.hasProperty('description')}">
<div style="line-height:14px;font-family:arial, ��tahoma, ��helvetica, ��sans-serif; font-size: 12px;">
 <g:if test="${bioDataObject?.description?.length() > 325000}">
                       ${(bioDataObject?.description)?.substring(0,324000)}&nbsp;&nbsp;
                       <a href=# >...See more</a>
                       </g:if>
                       <g:else>
                        ${bioDataObject?.description}
                        </g:else></div>
<div style="height:20px;"></div>
</g:if>
<g:elseif test="${bioDataObject?.hasProperty('longDescription')}">
<div style="line-height:14px;font-family:arial, ��tahoma, ��helvetica, ��sans-serif; font-size: 12px;">
 <g:if test="${bioDataObject?.longDescription?.length() > 325000}">
                       ${(bioDataObject?.longDescription)?.substring(0,324000)}&nbsp;&nbsp;
                       <a href=# >...See more</a>
                       </g:if>
                       <g:else>
                        ${bioDataObject?.longDescription}
                        </g:else></div>
<div style="height:20px;"></div>
</g:elseif>

<g:if test="${subjectLevelDataAvailable}">
	<center><div class="messagebox">Subject-level data is available for this study. <a href="${createLink(controller:'datasetExplorer', action:'index')}?accession=${bioDataObject.accession}">Open in Analyze view</a></div></center>
	<br/><br/>
</g:if>

<g:if test="${metaDataTagItems && metaDataTagItems.size()>0}">
<table class="details-table">
        <thead>
            <tr>                
                <th>&nbsp;</th>
                <th align="right">
				<g:if test="${!folder.folderType.equalsIgnoreCase(FolderType.ANALYSIS.name())}">
	                <%--<g:remoteLink controller="fmFolder" action="editMetaData" update="${overlayDiv}" 
                        params="[eleId:overlayDiv, folderId:folder?.id]" 
                        before="initLoadingDialog('${overlayDiv}')" onComplete="centerDialog('${overlayDiv}')">--%>
                  
                  <%-- Restrict edits to administrators if this is a PROGRAM or STUDY --%>
                  <g:if test="${folder.folderType.equalsIgnoreCase(FolderType.STUDY.name()) || folder.folderType.equalsIgnoreCase(FolderType.PROGRAM.name())}">
	                  <sec:ifAnyGranted roles="ROLE_ADMIN">
	                  	<img align="right" class="editmetadata" name="${folder?.id}" src="${resource(dir:'images', file:'pencil.png')}"/>
	                  </sec:ifAnyGranted>
                  </g:if>
                  <g:else>
					<img align="right" class="editmetadata" name="${folder?.id}" src="${resource(dir:'images', file:'pencil.png')}"/>
                  </g:else>
                  <%-- </g:remoteLink>--%>
                </g:if>
                </th>
            </tr>
        </thead>
    <tbody>
        <g:each in="${metaDataTagItems}" status="i" var="amTagItem">
          <g:if test="${amTagItem.viewInGrid}">
            <tr class='details-row'> <!-- class="${(i % 2) == 0 ? 'odd' : 'even'}"> -->
            <!-- TODO: If active -->
            
                <td valign="top" align="right" class="columnname" width="20%">${amTagItem.displayName}</td>
                <td valign="top" align="left" class="columnvalue" width="60%">
            
            <!-- FIXED -->
                 <g:if test="${amTagItem.tagItemType == 'FIXED'  && amTagItem.tagItemAttr!=null?bioDataObject?.hasProperty(amTagItem.tagItemAttr):false}" >
                 	<g:set var="fieldValue" value="${fieldValue(bean:bioDataObject,field:amTagItem.tagItemAttr)}"/>
                   	<g:if test="${amTagItem.tagItemSubtype == 'PICKLIST'}">
                 		<%-- Split multiple values by pipe --%>
                 		<g:set var="terms" value="${fieldValue.split('\\|')}"/>
                 		
                 		<g:each in="${terms}" var="term" status="t">
                 			<g:set var="bioDataId" value="${BioData.find('from BioData where uniqueId=?',[term])?.id}"/>
	                 		<g:if test="${t > 0}">, </g:if>
	                 		<g:if test="${bioDataId}">
		                 		${ConceptCode.find('from ConceptCode where id=?', bioDataId).codeName}
	                 		</g:if>
	                 		<g:else>
	                 			${term}
	                 		</g:else>
                 		</g:each>
                 	</g:if>
                  	<g:elseif test="${amTagItem.tagItemSubtype == 'MULTIPICKLIST'}">
                 		<%-- Split multiple values by pipe --%>
                 		<g:set var="terms" value="${fieldValue.split('\\|')}"/>
                 		
                 		<g:each in="${terms}" var="term" status="t">
                 			<g:set var="bioDataId" value="${BioData.find('from BioData where uniqueId=?',[term])?.id}"/>
	                 		<g:if test="${t > 0}">, </g:if>
	                 		<g:if test="${bioDataId}">
		                 		${ConceptCode.find('from ConceptCode where id=?', bioDataId).codeName}
	                 		</g:if>
	                 		<g:else>
	                 			${term}
	                 		</g:else>
                 		</g:each>
                 	</g:elseif>
                 	<g:else>
                 		${fieldValue}
                 	</g:else>
                </g:if>
			    <g:else>
                  <g:set var="tagValues" value="${AmTagDisplayValue.findAllDisplayValue(folder.getUniqueId(),amTagItem.id)}"/>
                    <g:if test="${tagValues!=null}">
	             		<g:each var="tagValue" status="k" in="${tagValues}">
							<g:if test="${k > 0 && tagValue.displayValue}">, </g:if>${tagValue.displayValue}				      
						</g:each>
					</g:if>
				</g:else>
				
				
                </td>
            </tr>
         </g:if>
        </g:each>
    </tbody>    
</table>
<span></span>
</g:if> 
                    
                   
<div style="height:20px;"></div>
<g:if test="${bioDataObject?.hasProperty('fmFiles') && null!=bioDataObject?.fmFiles && bioDataObject?.fmFiles.size()>0}">   
<div style="align:center;" ><h4 class="rdc-h4" align="center" >Associated Files</h4></div>
<table class="list-table">
            <thead>
                <tr>                
                    <th>File Name</th>
                    <th>Create Date</th>
                    <th>Update Date</th>
                    <th>&nbsp;</th>
                </tr>
            </thead>
		    <tfoot>
		    	<tr>
		    		<td colspan="3">&nbsp;</td>
	    		   <td>
		               <div style="padding: 4px 0px;">
		                    <span class="foldericon addall link">Export all</span>
		               </div>
	               </td>
		    	</tr>
		    </tfoot>
    <tbody>
        <g:each in="${bioDataObject?.fmFiles}" status="i" var="fmFile">
            <tr class="file-row">
                <td style="padding: 3px;"><span class="fileicon ${fmFile.fileType}"></span>&nbsp;${fmFile.displayName}</td>
               <td >
               <g:formatDate format="yyyy-MM-dd" date="${fmFile.createDate}" />
               </td> 
               <td >
               <g:formatDate format="yyyy-MM-dd" date="${fmFile.updateDate}" />
               </td> 
               <td>
	               <div>
	                    <span class="exportaddspan foldericon add link" name="${fmFile.id}">Add to export</span>
	               </div>
               </td>
                
            </tr>
        </g:each>
    </tbody>
</table>
</g:if>

<span></span>
                    
       <div style="height:20px;"></div>
      
         <g:each var='jSONForGrid' status="divCounter" in="${jSONForGrids}">
    	    <div style="width:1100px">
            <div id='gridViewWrapper${divCounter}'>
            </div>        
	        </div>
         </g:each>
         
<!--  overlay div  -->

<g:overlayDiv divId="${overlayDiv}" />
</div>
 
 <!-- background-color:#9CA4E4;  -->   
    
 
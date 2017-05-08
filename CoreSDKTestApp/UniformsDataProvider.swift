//
//  UniformsDataProvider.swift
//  CSSDKTestApp
//
//  Created by Vladimír Nevyhoštěný on 28.12.15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import CSCoreSDK
import CSUniforms

//==============================================================================
class UniformsDataProvider
{
    static let sharedInstance = UniformsDataProvider()
    
    let client = Uniforms().client
    
    //--------------------------------------------------------------------------
    var loaderQueue: DispatchQueue {
        if ( self._loaderQueue == nil ) {
            self._loaderQueue = DispatchQueue( label: "uniforms.loader.queue", attributes: [] )
        }
        return self._loaderQueue!
    }
    
    //--------------------------------------------------------------------------
    var lockQueue: DispatchQueue {
        if ( self._lockQueue == nil ) {
            self._lockQueue = DispatchQueue( label: "uniforms.lock.queue", attributes: [] )
        }
        return self._lockQueue!
    }
    
    fileprivate var _loaderQueue: DispatchQueue?
    fileprivate var _lockQueue: DispatchQueue?
    
    //--------------------------------------------------------------------------
    fileprivate init()
    {
    }
    
    //--------------------------------------------------------------------------
    func loadFormsList(_ callback: @escaping (_ result: CoreResult<ListResponse<FormListItem>>) -> Void)
    {
        self.client?.forms.list( callback )
    }
    
    //--------------------------------------------------------------------------
    func loadFormWithId( _ formId: Int, callback: @escaping (_ result: CoreResult<Form>) -> Void)
    {
        self.client?.forms.withId(formId).get( callback )
    }
    
    //--------------------------------------------------------------------------
    func saveForm( _ form: Form, values: [FilledFormField], callback: @escaping (_ result: CSCoreSDK.CoreResult<CSUniforms.FilledForm>) -> Void )
    {
        self.loaderQueue.async(execute: {
            
            let saveRequest     = FilledFormRequest()
            saveRequest.formId  = form.id
            saveRequest.fields  = values
            
            self.client?.filledForms.create(saveRequest) { result in
                callback( result )
            }
            
        })
    }
    
    //--------------------------------------------------------------------------
    func uploadAttachment( _ fieldId: Int, fileName: String, documentData: Data, callback: @escaping ( _ result: CSCoreSDK.CoreResult<[FilledFormFieldWithMessages]>) -> Void )
    {
        let attachmentRequest = AttachmentCreateRequest(fileName: fileName, data: documentData )
        self.client?.attachments.upload(attachmentRequest) { (result) -> Void in
            switch result {
            case .success(let file ):
                if file.isOk {
                    callback( CSCoreSDK.CoreResult.success( [FilledFormFieldWithMessages.init(fieldId: fieldId, values: [file.id], messages: nil)] ) )
                }
                else {
                    callback( CSCoreSDK.CoreResult.failure( CoreSDKError.errorWithCode(CoreSDKErrorKind.attachmentUploadFailed.rawValue)! ) )
                }
                
            case .failure( let error ):
                callback( CSCoreSDK.CoreResult.failure( error ) )
            }
        }
    }
    
}

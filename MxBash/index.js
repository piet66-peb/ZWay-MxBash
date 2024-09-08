/*** MxBash V2.4.1 2024-09-08 Z-Way HA module *********************************/

//h-------------------------------------------------------------------------------
//h
//h Name:         index.js
//h Type:         Javascript code for Z-Way module MxBash
//h Purpose:      
//h Project:      Z-Way HA
//h Usage:        
//h Remark:       
//h Result:       
//h Examples:     
//h Outline:      
//h Resources:    AutomationModule
//h Issues:       
//h Authors:      peb Peter M. Ebert
//h Version:      V2.4.1 2024-09-08/peb
//v History:      V1.0.0 2023-08-01/peb first version
//h Copyright:    (C) Peter M. Ebert 2019
//h License:      http://opensource.org/licenses/MIT
//h 
//h-------------------------------------------------------------------------------
/*jshint esversion: 5 */
/*jshint strict: false */
/*globals inherits, _module: true, AutomationModule */

//h-------------------------------------------------------------------------------
//h
//h Name:         MxBash
//h Purpose:      create module subclass.
//h
//h-------------------------------------------------------------------------------
function MxBash(id, controller) {
    // Call superconstructor first (AutomationModule)
    MxBash.super_.call(this, id, controller);

    this.MODULE='index.js';
    this.VERSION='V2.4.1';
    this.WRITTEN='2024-09-08/peb';
}
inherits(MxBash, AutomationModule);
_module = MxBash;

//h-------------------------------------------------------------------------------
//h
//h Name:         init
//h Purpose:      module initialization.
//h
//h-------------------------------------------------------------------------------
MxBash.prototype.init = function(config) {
    MxBash.super_.prototype.init.call(this, config);
    var self = this;

    //b nothing to do
    //---------------
    
}; //init

//h-------------------------------------------------------------------------------
//h
//h Name:         stop
//h Purpose:      module stop.
//h
//h-------------------------------------------------------------------------------
MxBash.prototype.stop = function() {
    var self = this;

    //b nothing to do
    //---------------

    MxBash.super_.prototype.stop.call(this);
}; //stop


// -- copyright
// OpenProject is an open source project management software.
// Copyright (C) 2012-2023 the OpenProject GmbH
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See COPYRIGHT and LICENSE files for more details.
//++

import { ChangeDetectorRef, Component, ElementRef, Inject, Injector } from '@angular/core';
import { DatePickerEditFieldComponent } from 'core-app/shared/components/fields/edit/field-types/date-picker-edit-field.component';
import { WorkPackageResource } from 'core-app/features/hal/resources/work-package-resource';
import { I18nService } from 'core-app/core/i18n/i18n.service';
import { OpEditingPortalChangesetToken, OpEditingPortalHandlerToken, OpEditingPortalSchemaToken } from '../edit-field.component';
import { EditFieldHandler } from '../editing-portal/edit-field-handler';
import { IFieldSchema } from '../../field.base';
import { ResourceChangeset } from '../../changeset/resource-changeset';
import { HalResource } from 'core-app/features/hal/resources/hal-resource';
import { DateModalRelationsService } from 'core-app/shared/components/datepicker/services/date-modal-relations.service';
import { DateModalSchedulingService } from 'core-app/shared/components/datepicker/services/date-modal-scheduling.service';
import { WorkPackageChangeset } from 'core-app/features/work-packages/components/wp-edit/work-package-changeset';
import { mappedDate } from 'core-app/shared/components/datepicker/helpers/date-modal.helpers';

@Component({
  templateUrl: './combined-date-edit-field.component.html',
  providers: [
    DateModalRelationsService,
    DateModalSchedulingService,
  ],
})
export class CombinedDateEditFieldComponent extends DatePickerEditFieldComponent {
  minimumDate:Date|null = null;

  dates = '';

  isOpened = true;

  text = {
    placeholder: {
      startDate: this.I18n.t('js.label_no_start_date'),
      dueDate: this.I18n.t('js.label_no_due_date'),
      date: this.I18n.t('js.label_no_date'),
    },
  };

  constructor(
    readonly I18n:I18nService,
    readonly elementRef:ElementRef,
    @Inject(OpEditingPortalChangesetToken) protected change:ResourceChangeset<HalResource>,
    @Inject(OpEditingPortalSchemaToken) public schema:IFieldSchema,
    @Inject(OpEditingPortalHandlerToken) readonly handler:EditFieldHandler,
    readonly cdRef:ChangeDetectorRef,
    readonly injector:Injector,
  ) {
    super(
      I18n,
      elementRef,
      change,
      schema,
      handler,
      cdRef,
      injector,
   );
  }

  ngOnInit():void {
    this.dateModalRelations.setChangeset(this.change as WorkPackageChangeset);
    this.dateModalScheduling.setChangeset(this.change as WorkPackageChangeset);

    this
      .dateModalRelations
      .getMinimalDateFromPreceeding()
      .subscribe((date) => {
        this.minimumDate = date;
      });
  }

  get isMultiDate():boolean {
    return !this.change.schema.isMilestone;

    /*
    this
      .modal
      ?.onDataUpdated
      .subscribe((dates:string) => {
        this.dates = dates;
        this.cdRef.detectChanges();
      });
    */
  }

  public onModalClosed():void {
    this.isOpened = false;
    this.resetDates();
    super.onModalClosed();
  }

  public updateNonWorkingDays(ignoreNonWorkingDays:boolean):void {
    this.change.setValue('ignoreNonWorkingDays', ignoreNonWorkingDays);
  }

  public save(date:string):void {
    // Apply the dates if they could be changed
    if (this.dateModalScheduling.isSchedulable) {
      this.change.setValue('date', mappedDate(date));
    }

    this.handler.handleUserSubmit();
  }

  public cancel():void {
    this.handler.handleUserCancel();
  }

  // Overwrite super in order to set the initial dates.
  protected initialize():void {
    super.initialize();
    this.resetDates();
  }

  protected resetDates():void {
    switch (this.name) {
      case 'combinedDate':
        this.dates = `${this.current('startDate')} - ${this.current('dueDate')}`;
        break;

      case 'startDate':
        this.dates = `${this.current('startDate')}`;
        break;

      case 'dueDate':
        this.dates = `${this.current('dueDate')}`;
        break;

      case 'date':
        this.dates = `${this.current('date')}`;
        break;

      default:
        break;
    }
  }

  protected current(dateAttribute:'startDate' | 'dueDate' | 'date'):string {
    const value = (this.resource && (this.resource as WorkPackageResource)[dateAttribute]) as string|null;
    return (value || this.text.placeholder[dateAttribute]);
  }
}

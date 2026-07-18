package com.example.demo.service;

import com.example.demo.dto.*;

import com.example.demo.dto.TodayScheduleDTO;

import com.example.demo.entity.*;

import com.example.demo.repository.*;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;



@Service
public class TeacherService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TeacherRepository teacherRepository;


    @Autowired
    private ClassesRepository classesRepository;


    @Autowired
    private ScheduleRepository scheduleRepository;


    @Autowired
    private SubjectRepository subjectRepository;

    @Autowired
    private ClassStudentRepository classStudentRepository;

    @Autowired
    private RoomRepository roomRepository;
    @Autowired
    private TimeSlotRepository timeSlotRepository;

    // Dashboard giáo viên
    public TeacherDashboardResponse getTeacherDashboard(Integer userId) {
        Optional<Teacher> teacherOptional =
                teacherRepository.findByUserId(userId);

        if (teacherOptional.isEmpty()) {
            return new TeacherDashboardResponse();
        }
        Teacher teacher = teacherOptional.get();
        // Lấy danh sách lớp giáo viên phụ trách

        List<Classes> classes =
                classesRepository.findByMainTeacherId(
                        teacher.getTeacherId()
                );

        List<TeacherClassDTO> classDTOList =
                new ArrayList<>();
        for (Classes classesItem : classes) {
            String subjectName = "";
            Optional<Subject> subject =
                    subjectRepository.findById(
                            classesItem.getSubjectId()
                    );
            if(subject.isPresent()){
                subjectName =
                        subject.get().getSubjectName();

            }

            Integer studentCount =
                    classStudentRepository.countByClassId(
                            classesItem.getClassId()
                    );

            TeacherClassDTO dto =
                    new TeacherClassDTO(
                            classesItem.getClassId(),
                            classesItem.getClassCode(),
                            classesItem.getClassName(),
                            subjectName,
                            studentCount,
                            classesItem.getStatus()
                    );


            classDTOList.add(dto);

        }




        // Lấy lịch hôm nay


        LocalDate today = LocalDate.now();



        List<Integer> classIds =
                new ArrayList<>();



        for(Classes classesItem : classes){

            classIds.add(
                    classesItem.getClassId()
            );

        }



        List<Schedule> schedules =
                scheduleRepository
                        .findByClassIdInOrderByScheduleDateAscTimeSlotIdAsc(
                                classIds
                        );



        List<TodayScheduleDTO> todayScheduleList =
                new ArrayList<>();

        for(Schedule schedule : schedules){
            if(!schedule.getScheduleDate().equals(today)){
                continue;
            }
                Classes currentClass = null;

                for(Classes classesItem : classes){
                    if(classesItem.getClassId()
                            .equals(schedule.getClassId())){
                        currentClass = classesItem;
                        break;
                    }
                }
                if(currentClass != null){
                    String subjectName = "";

                    Optional<Subject> subject =
                            subjectRepository.findById(
                                    currentClass.getSubjectId()
                            );
                    if(subject.isPresent()){

                        subjectName =
                                subject.get()
                                        .getSubjectName();

                    }
                    String roomName = "";

                    Optional<Room> room =
                            roomRepository.findById(
                                    schedule.getRoomId()
                            );
                    if(room.isPresent()){

                        roomName =
                                room.get()
                                        .getRoomName();

                    }

                    String startTime = "";
                    String endTime = "";
                    Optional<TimeSlot> timeSlot =
                            timeSlotRepository.findById(
                                    schedule.getTimeSlotId()
                            );
                    if(timeSlot.isPresent()){


                        LocalTime start =
                                timeSlot.get()
                                        .getStartTime();
                        LocalTime end =
                                timeSlot.get()
                                        .getEndTime();



                        startTime =
                                start.toString();


                        endTime =
                                end.toString();

                    }

                    TodayScheduleDTO scheduleDTO =
                            new TodayScheduleDTO(
                                    schedule.getScheduleId(),

                                    currentClass.getClassId(),

                                    currentClass.getClassCode(),

                                    currentClass.getClassName(),

                                    subjectName,

                                    roomName,

                                    startTime,

                                    endTime,

                                    schedule.getScheduleDate().toString()
                            );



                    todayScheduleList.add(scheduleDTO);


                }


        }
        TeacherDashboardResponse response =
                new TeacherDashboardResponse();
        response.setTeacherId(
                teacher.getTeacherId()
        );

        String teacherName = "";
        Optional<User> user =
                userRepository.findById(
                        teacher.getUserId()
                );
        if(user.isPresent()){
            teacherName =
                    user.get().getFullName();
        }
        response.setTeacherName(
                teacherName
        );

        response.setTotalClasses(
                classes.size()
        );

        response.setTodaySchedules(
                todayScheduleList.size()
        );


        // tạm thời chưa xử lý attendance
        response.setPendingAttendance(0);

        // tạm thời chưa xử lý grade

        response.setPendingGrades(0);

        response.setClasses(
                classDTOList
        );


        response.setTodaySchedule(
                todayScheduleList
        );

        return response;

    }
    // Lấy thông tin teacher theo UserId
    public Optional<Teacher> getTeacherByUserId(Integer userId){
        return teacherRepository.findByUserId(userId);

    }
    public List<TeacherScheduleDTO> getTeacherSchedule(Integer userId) {

        Optional<Teacher> teacherOptional =
                teacherRepository.findByUserId(userId);

        if (teacherOptional.isEmpty()) {
            return new ArrayList<>();
        }

        Teacher teacher = teacherOptional.get();

        List<Classes> classes =
                classesRepository.findByMainTeacherId(
                        teacher.getTeacherId()
                );

        List<Integer> classIds =
                new ArrayList<>();

        for (Classes item : classes) {
            classIds.add(item.getClassId());
        }

        List<Schedule> schedules =
                scheduleRepository
                        .findByClassIdInOrderByScheduleDateAscTimeSlotIdAsc(classIds);

        List<TeacherScheduleDTO> result =
                new ArrayList<>();

        for (Schedule schedule : schedules) {

            Classes currentClass = null;

            for (Classes item : classes) {

                if (item.getClassId().equals(schedule.getClassId())) {

                    currentClass = item;
                    break;

                }

            }

            if (currentClass == null) {
                continue;
            }

            String subjectName = "";

            Optional<Subject> subject =
                    subjectRepository.findById(
                            currentClass.getSubjectId()
                    );

            if (subject.isPresent()) {
                subjectName = subject.get().getSubjectName();
            }

            String roomName = "";

            Optional<Room> room =
                    roomRepository.findById(
                            schedule.getRoomId()
                    );

            if (room.isPresent()) {
                roomName = room.get().getRoomName();
            }

            String startTime = "";
            String endTime = "";

            Optional<TimeSlot> timeSlot =
                    timeSlotRepository.findById(
                            schedule.getTimeSlotId()
                    );

            if (timeSlot.isPresent()) {

                startTime =
                        timeSlot.get().getStartTime().toString();

                endTime =
                        timeSlot.get().getEndTime().toString();

            }

            TeacherScheduleDTO dto =
                    new TeacherScheduleDTO(

                            schedule.getScheduleId(),

                            currentClass.getClassId(),

                            currentClass.getClassCode(),

                            currentClass.getClassName(),

                            subjectName,

                            roomName,

                            schedule.getScheduleDate().toString(),

                            startTime,

                            endTime,

                            schedule.getStatus()

                    );

            result.add(dto);

        }

        return result;

    }
    public List<TeacherClassDTO> getTeacherClasses(Integer userId) {


        Optional<Teacher> teacherOptional =
                teacherRepository.findByUserId(userId);


        if(teacherOptional.isEmpty()){

            return new ArrayList<>();

        }


        Teacher teacher = teacherOptional.get();



        List<Classes> classes =
                classesRepository.findByMainTeacherId(
                        teacher.getTeacherId()
                );


        List<TeacherClassDTO> result =
                new ArrayList<>();



        for(Classes item : classes){


            String subjectName = "";


            Optional<Subject> subject =
                    subjectRepository.findById(
                            item.getSubjectId()
                    );


            if(subject.isPresent()){

                subjectName =
                        subject.get()
                                .getSubjectName();

            }



            TeacherClassDTO dto =
                    new TeacherClassDTO(

                            item.getClassId(),

                            item.getClassCode(),

                            item.getClassName(),

                            subjectName

                    );


            result.add(dto);

        }


        return result;

    }


}